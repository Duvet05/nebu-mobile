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
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`

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
  artifact.
- `CI` now includes:
  - `Analyze`
  - `Format check`
  - `Unit tests` (placeholder-safe no-op when no `test/` suite exists yet)
  - `Android debug build`
  - `Android e2e` (`workflow_dispatch` to run)
  - `CodeQL` security scan
  - `Dependency Review` on pull requests

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
