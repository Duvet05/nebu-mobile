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

- `Build & Publish Android` builds a signed AAB with the Triplet Play Publisher
  plugin wiring available for uploads:
  - Push to `main`: build the signed AAB and keep it as a GitHub artifact. This
    does not publish to Google Play.
  - Push tag `v*.*.*`: build the signed AAB, keep it as an artifact, and publish
    it to the `internal` Play track with release status `COMPLETED`.
  - `workflow_dispatch`: build the signed AAB and optionally publish it. Use
    `publish_to_play=false` for a build-only run, or keep `publish_to_play=true`
    and choose the Play track (`internal`, `alpha`, `beta`, `production`, or a
    custom closed-testing track) plus release status.
  - AAB artifacts are uploaded before Play publishing, so a Play API failure does
    not lose the signed bundle.
- `Build iOS` builds a signed `Runner.ipa` (`flutter build ipa`), uploads it to
  App Store Connect/TestFlight using `xcrun altool`, and keeps the IPA as an
  artifact. You can run it with `upload_to_app_store=false` to skip App Store
  signing and upload while still keeping the job green.
- `CI` now includes:
  - `Analyze`
  - `Format check`
  - `Unit tests` (placeholder-safe no-op when no `test/` suite exists yet)
  - `Web release build`
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

- Google Play requires every uploaded Android `versionCode` to be greater than
  all previously uploaded bundles. The Android CI workflow now overrides the
  Flutter build number with `ANDROID_VERSION_CODE_OFFSET + GITHUB_RUN_NUMBER`
  unless `build_number` is provided manually. The current offset is `1000`, so
  the next automated bundle will not collide with the existing Play bundle
  `34`.
- Use release status `COMPLETED` when an internal-testing build should become
  available to testers immediately. Use `DRAFT` when the bundle should only be
  staged for manual review in Play Console.
- Increase the Flutter build number in `pubspec.yaml` for local store builds and
  iOS/App Store uploads. Android CI has its own monotonic build-number override.
- Keep LiveKit API keys, LiveKit API secrets, MongoDB, JWT, and OpenAI keys on
  the backend only. Do not compile those into the mobile app.
- For signed iOS/TestFlight CI, add Apple certificate/provisioning/App Store
  Connect API secrets and replace the no-codesign build with `flutter build ipa`.

## Android release runbook

Build a signed AAB without publishing:

1. Open GitHub Actions.
2. Run `Build & Publish Android`.
3. Set `publish_to_play=false`.
4. Download the `release-aab-<run_id>` artifact after the job completes.

Publish a build to internal testers:

1. Create and push a version tag from the commit that should ship:
   ```sh
   git tag v1.2.3
   git push origin v1.2.3
   ```
2. Confirm the workflow summary shows the expected build name, generated build
   number, `internal` track, and `COMPLETED` release status.
3. Check Play Console under `Test and release > Internal testing`. The new
   release should be available to testers after Google finishes processing the
   bundle.

Manual Play upload:

1. Run `Build & Publish Android` with `publish_to_play=true`.
2. Set `play_track=internal` for tester builds.
3. Set `release_status=COMPLETED` to make the release available, or `DRAFT` to
   stage it without tester rollout.
4. Provide `build_number` only when you need a specific Play version code. It
   must be greater than every existing version code in Play Console.

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
