# Web WiFi provisioning

Last reviewed: 2026-06-28.

This document maps the risks and expected behavior for configuring an ESP32
Nebu device from the Flutter web app through Web Bluetooth.

## Scope

The web flow starts at `/setup/connection`, requests a Bluetooth device through
the browser picker, opens the ESP32 WiFi GATT service, and passes that live
service object to `/setup/wifi`.

The mobile flow still uses `flutter_blue_plus` through
`ESP32WifiConfigService`. The web flow uses the conditional
`WebWifiConfigSession` implementation.

## Risk map

| Risk | Severity | Current status | Owner |
| --- | --- | --- | --- |
| Browser does not support Web Bluetooth | High | Mitigated with HTTPS deploy and in-app browser notice | App |
| `/setup/wifi` is opened without a live BLE session | High | Mitigated with reconnect snackbar/action | App |
| Web flow sends WiFi but does not persist `DEVICE_ID` | High | Fixed by reading and storing `DEVICE_ID` when available | App/Firmware |
| Optional `DEVICE_ID` read blocks navigation | Medium | Mitigated with a bounded read timeout | App |
| Credential write hangs before connection timeout starts | Medium | Mitigated with a bounded credential-send timeout | App |
| WiFi password leaks into BLE debug logs | High | Fixed by redacting password characteristic writes | App |
| Mobile BLE writes skip response when both write modes exist | Medium | Fixed by preferring write-with-response | App |
| Firmware UUID or characteristic contract differs | High | Documented; requires firmware verification | Firmware |
| Device is not shown in browser picker | Medium | Requires advertised name prefix or service advertisement | Firmware/App |
| STATUS is missing, unreadable, or not notifiable | Medium | App falls back to polling and timeout/continue | App/Firmware |
| Late STATUS arrives after user cancels | Medium | Mitigated by ignoring non-idle status when not actively connecting | App |
| User taps "wait" in timeout dialog and never gets another prompt | Low | Fixed by restarting the timeout timer | App |
| GATT connection drops between setup screens | Medium | User sees reconnect/send failure path | Browser/App |
| Web target is JS-only today, not Wasm-ready | Medium | Build passes JS; Wasm dry run warns on storage dependency | App |
| User-facing text hardcoded outside i18n | Low | Fixed for Web Bluetooth notice | App |

## Detailed analysis

### 1. Browser support

Web Bluetooth is not a general web platform capability across all browsers.
The expected supported path is Chrome or Edge over HTTPS. Safari, iOS browsers,
and Firefox are not reliable targets for this flow.

Code path:

- `ConnectionSetupScreen._connectViaWebBluetooth()` checks
  `navigator.bluetooth`.
- Vercel serves production over HTTPS at `https://app.flow-telligence.com`.
- The UI now shows a localized browser-support notice on web.

Failure mode:

- Unsupported browsers throw before the browser picker opens.
- The app shows the normal connection failure snackbar unless the browser
  reports user cancellation.

Manual QA:

- Open `https://app.flow-telligence.com/#/setup/connection` in Chrome or Edge.
- Confirm the browser picker opens only after the user clicks start scan.
- Confirm Safari/Firefox show the failure path instead of a stuck loading state.

### 2. Live BLE session requirement

The web WiFi screen requires a live `BluetoothRemoteGATTService` object passed
through `go_router` extra data. That object is runtime-only and cannot survive
a page refresh, a copied direct URL, or browser history restoration that
recreates the route without extras.

Code path:

- `ConnectionSetupScreen` passes `bleService` to `WifiSetupScreen`.
- `WifiSetupScreen` creates `WebWifiConfigSession(widget.webBleService)`.
- If web opens `/setup/wifi` without `webBleService`, the app now shows a
  reconnect snackbar with an action back to `/setup/connection`.

Failure mode:

- Without the guard, users could fill SSID/password and get a generic send
  failure because no GATT service existed.
- With the guard, the user gets a specific reconnect action before sending.

Manual QA:

- Open `/setup/wifi` directly in a browser.
- Confirm the reconnect snackbar appears.
- Click reconnect and confirm the app returns to `/setup/connection`.

### 3. Device ID persistence

The next setup step can register the toy only if `StorageKeys.currentDeviceId`
has been saved. Mobile already does this in `ESP32WifiConfigService` after
discovering the optional `DEVICE_ID` characteristic. Web must match that
behavior.

Code path:

- Mobile: `ESP32WifiConfigService.readDeviceId()` stores
  `StorageKeys.currentDeviceId`.
- Web: `WebWifiConfigSession.readDeviceId()` reads
  `BleConstants.esp32DeviceIdCharUuid`.
- `WifiSetupScreen` stores the web `DEVICE_ID` after credentials are sent,
  again before navigating on `CONNECTED`, and again before continuing from the
  timeout dialog.
- `ToyNameSetupScreen._registerDeviceIfNeeded()` consumes
  `StorageKeys.currentDeviceId` to create the toy for authenticated users.

Failure mode:

- If firmware does not expose a readable `DEVICE_ID`, WiFi can still be
  provisioned but backend toy registration is skipped in the name step.
- This is treated as a firmware contract issue, not a web transport issue.
- If the browser or firmware stalls the optional `DEVICE_ID` read, navigation
  still continues after a short timeout.

Manual QA:

- After a successful web WiFi provisioning run, inspect local app storage or
  continue through toy name while authenticated.
- Confirm the backend receives `deviceId` during toy creation.

### 4. Firmware GATT contract

The app and firmware must agree on these UUIDs:

| Purpose | UUID | Required |
| --- | --- | --- |
| WiFi service | `0000bc9a-7856-3412-3412-341278563412` | Yes |
| SSID characteristic | `0000bd9a-7856-3412-3412-341278563412` | Yes |
| Password characteristic | `0000be9a-7856-3412-3412-341278563412` | Yes |
| Status characteristic | `0000bf9a-7856-3412-3412-341278563412` | Recommended |
| Device ID characteristic | `0000c09a-7856-3412-3412-341278563412` | Recommended for registration |

Write format:

- SSID and password are UTF-8 strings.
- The app tries `writeValueWithResponse` first and falls back to legacy
  `writeValue`.
- The mobile BLE handler also prefers write-with-response when both write modes
  are available.
- Credential writes are bounded by a send timeout so the UI cannot spin
  indefinitely before the connection-status timer starts.
- SSID must be at most 32 UTF-8 bytes.
- Password must be empty for open networks or 8-63 characters for secured
  networks.
- Password characteristic writes are redacted in BLE logs.

Status format:

- STATUS should return or notify one of `IDLE`, `CONNECTING`, `CONNECTED`,
  `RECONNECTING`, or `FAILED`.
- Values are decoded as UTF-8 and trimmed.

Failure mode:

- Missing SSID/PASSWORD characteristics block credential send.
- Missing STATUS does not block send, but the app cannot auto-confirm success
  and relies on timeout/continue.
- Missing readable `DEVICE_ID` blocks automatic toy registration after setup.

### 5. Device discovery

The browser picker uses name-prefix filters for `Nebu`, `ESP32`, and `nebu`,
with the WiFi service UUID listed as an optional service so the app can access
it after selection.

Failure mode:

- A device that advertises a different name may not appear.
- A device that does not expose the WiFi service after connection fails service
  discovery.

Firmware requirement:

- Advertise a user-visible local name starting with `Nebu`, `nebu`, or `ESP32`,
  or update the app filter if production firmware uses a different prefix.
- Expose the WiFi service and required characteristics immediately after GATT
  connection.

Future hardening:

- Add a service UUID filter if production firmware reliably advertises the
  custom service UUID in the BLE advertisement.

### 6. STATUS notification and polling

The app subscribes to `characteristicvaluechanged` when STATUS supports
notifications. It also polls `readValue` every two seconds when STATUS is
readable.

Failure mode:

- If STATUS is neither notifiable nor readable, credentials may be written but
  the UI cannot know whether the ESP32 joined WiFi.
- The user sees the timeout dialog after 45 seconds and can continue setup or
  retry.
- If the user chooses to keep waiting, the app restarts the timeout timer so
  they are prompted again instead of waiting indefinitely.
- If the user cancels the WiFi attempt, late `CONNECTED` or `FAILED` statuses
  are ignored so the app does not navigate unexpectedly.

Manual QA:

- Test firmware with STATUS notify enabled.
- Test firmware with STATUS read-only.
- Confirm both `CONNECTED` and `FAILED` update the UI.

### 7. GATT disconnects

Browsers may drop the GATT connection when the device reboots, leaves range,
or the tab loses focus. Credential writes and reads then reject.

Current behavior:

- Send failures show `setup.wifi.error_send_credentials`.
- Direct/no-session web state shows the reconnect snackbar.
- STATUS stream completion stops the spinner and shows the BLE disconnected
  error.

Manual QA:

- Disconnect or reboot the ESP32 after opening WiFi setup.
- Confirm the app does not remain stuck in loading state.

### 8. Web build target

The production deploy is a Flutter JS web build. `flutter build web --release`
passes. The Flutter Wasm dry run currently warns because
`flutter_secure_storage_web` depends on `dart:html`/`dart:js_util`.

Current target:

- Supported: Flutter web JS build on HTTPS.
- Not validated: Flutter Wasm build.

## Validation checklist

Run before merging or redeploying the web WiFi flow:

```sh
flutter analyze
flutter test
flutter build web --release
```

Then verify the generated/public bundle contains the Web Bluetooth contract:

```sh
rg "0000bc9a|0000c09a|writeValueWithResponse|startNotifications|characteristicvaluechanged" build/web/main.dart.js
```

Production smoke test:

```sh
curl -sI https://app.flow-telligence.com/
curl -sI https://app.flow-telligence.com/setup/connection
```

Manual hardware QA remains required for final confidence:

1. Open `https://app.flow-telligence.com/#/setup/connection` in Chrome or Edge.
2. Select a Nebu/ESP32 device from the browser Bluetooth picker.
3. Confirm WiFi setup opens after service discovery.
4. Enter SSID/password and confirm firmware receives both writes.
5. Confirm STATUS `CONNECTED` advances to toy name setup.
6. Confirm the device ID is persisted and toy registration receives `deviceId`.
7. Repeat with bad WiFi credentials and confirm STATUS `FAILED` shows retry.
