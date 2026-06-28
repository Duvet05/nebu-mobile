# Production release

## GitHub repository variables

These values are compiled into the Flutter app with `--dart-define`.

- `API_URL`
- `SERVER_URL`
- `WS_URL`
- `LIVEKIT_URL`
- `GOOGLE_WEB_CLIENT_ID`
- `GOOGLE_IOS_CLIENT_ID`
- `FACEBOOK_APP_ID` if Facebook auth is enabled

The app has production defaults for the Flow Telligence API, WebSocket, LiveKit,
and Google web client ID, so only override values that differ by environment.

## GitHub repository secrets

Android release:

- `GOOGLE_SERVICES_JSON_BASE64`
- `UPLOAD_KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`
- `PLAY_SERVICE_ACCOUNT_JSON`

iOS release verification:

- `GOOGLE_SERVICE_INFO_PLIST_BASE64`

App Store (signed upload) release:

- `APP_STORE_TEAM_ID` (GitHub variable) or use default from project signing config.
- `APP_STORE_BUNDLE_ID` (GitHub variable, defaults to `com.nebu.nebuMobileFlutter`).
- `APP_STORE_DISTRIBUTION_P12_BASE64`
- `APP_STORE_DISTRIBUTION_P12_PASSWORD`
- `APP_STORE_PROVISIONING_PROFILE_BASE64`
- `APP_STORE_PROVISIONING_PROFILE_NAME`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID` (`APP_STORE_CONNECT_API_KEY_ISSUER_ID` is also supported)
- `APP_STORE_CONNECT_API_KEY_BASE64`

If the workflow runs with `upload_to_app_store=true` and any of these are missing,
it fails fast with explicit `Missing GitHub secret ...` messages.

Encode local files without newlines before adding them as GitHub secrets:

```sh
base64 -i android/app/google-services.json | tr -d '\n'
base64 -i android/upload-keystore.jks | tr -d '\n'
base64 -i android/service-account.json | tr -d '\n'
base64 -i ios/Runner/GoogleService-Info.plist | tr -d '\n'
base64 -i ios/certificates/AppStoreDistribution.p12 | tr -d '\n'
base64 -i ios/profiles/AppStore_Provisioning_Profile.mobileprovision | tr -d '\n'
base64 -i ios/AuthKey_{YOUR_KEY_ID}.p8 | tr -d '\n'
```

## Workflows

- `Build & Publish Android` builds an AAB and publishes it with the Triplet Play
  Publisher plugin. Use `workflow_dispatch` to choose the Play track
  (`internal`, `alpha`, `beta`, `production`, or a custom closed-testing track)
  and release status (`DRAFT` by default).
- `Build iOS` builds a signed `Runner.ipa` (`flutter build ipa`), uploads it to
  App Store Connect/TestFlight using `xcrun altool`, and keeps the IPA as an
  artifact. You can run it with `upload_to_app_store=false` to skip App Store
  signing and upload while still keeping the job green.
- `CI` now includes:
  - `Analyze`
  - `Format check`
  - `Unit tests` (placeholder-safe no-op when no `test/` suite exists yet)
  - `Android debug build`
  - `Android e2e` (`workflow_dispatch` to run)
  - `CodeQL` security scan
  - `Dependency Review` on pull requests

## Web production deploy

The Flutter web production target is the JS build served from Vercel:

```sh
flutter build web --release
vercel deploy build/web --prod --archive=tgz --project nebu-mobile --yes
```

The public production aliases are:

- `https://app.flow-telligence.com`
- `https://nebu-mobile.vercel.app`

Backend CORS must allow every public web origin that serves this Flutter app.
For the current production backend, keep these origins in the backend
`IOT_ALLOWED_ORIGINS`/CORS allowlist:

- `https://app.flow-telligence.com`
- `https://nebu-mobile.vercel.app`

Registration and login can pass direct API tests but still fail in the browser
when the active app origin is missing from that allowlist.

Production auth smoke checks:

```sh
curl -sS -D - -o /dev/null \
  -X OPTIONS https://api.flow-telligence.com/api/v1/auth/register \
  -H 'Origin: https://app.flow-telligence.com' \
  -H 'Access-Control-Request-Method: POST' \
  -H 'Access-Control-Request-Headers: content-type'
```

Expected headers include:

- `access-control-allow-origin: https://app.flow-telligence.com`
- `access-control-allow-credentials: true`

For browser-level validation, run a Playwright smoke against the deployed app
with a unique disposable email, assert `POST /api/v1/auth/register` returns
`201`, and clean the test user plus related `subscriptions`, `person_names`,
`persons`, and `email_logs` records from production data afterwards.

The web WiFi provisioning flow depends on Web Bluetooth and is documented in
[`docs/web-wifi-provisioning.md`](web-wifi-provisioning.md). Before deploying
changes to `/setup/connection` or `/setup/wifi`, run the validation checklist
from that document and confirm `/setup/connection` returns `200` after deploy.

## Branch protection

- Main is protected to require pull requests with at least one approving review and
  minimum status checks: `CI / Analyze`, `CI / Format check`, `CI / Unit tests`,
  `CI / Android debug build`.

## Store notes

- Increase the Flutter build number for every Play Store or App Store upload.
- Keep LiveKit API keys, LiveKit API secrets, MongoDB, JWT, and OpenAI keys on
  the backend only. Do not compile those into the mobile app.
- For signed iOS/TestFlight CI, add Apple certificate/provisioning/App Store
  Connect API secrets and replace the no-codesign build with `flutter build ipa`.

## Technical debt

- **Consolidate GCP projects**: Nebu currently uses two GCP projects under the
  PUCP organization (`pucp.pe`, org ID `642164415054`):
  - `nebu-b65d4` — Firebase (Core, Crashlytics, FCM), Google Sign-In, OAuth clients
  - `nebu-486902` — Play Store publishing service account (`nebu-104@nebu-486902.iam.gserviceaccount.com`)

  The PUCP org enforces `iam.managed.disableServiceAccountKeyCreation`, preventing
  new service account key creation. The existing key works but cannot be rotated.
  Plan: migrate both projects to a personal Google account outside PUCP to gain
  full control. This requires re-creating Firebase config, OAuth clients, and
  updating all GitHub secrets.
