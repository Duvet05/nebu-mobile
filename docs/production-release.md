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
- `IOS_MINIMAL_RELEASE` (`true` to use the limited iPhone-only feature set for tag builds)

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

For full releases, the App Store provisioning profile must be regenerated after
enabling these capabilities for the app identifier in Apple Developer:

- Associated Domains, including `applinks:nebu.flow-telligence.com`
- Sign in with Apple
- Push Notifications, required for FCM/APNs delivery

The iOS workflow validates these capabilities before building the signed IPA.
Minimum releases omit Associated Domains so they can use the current profile;
Sign in with Apple and Push Notifications remain required.

Encode local files without newlines before adding them as GitHub secrets:

```sh
base64 -i android/app/google-services.json | tr -d '\n'
base64 -i android/upload-keystore.jks | tr -d '\n'
base64 -i android/service-account.json | tr -d '\n'
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
- Xcode Cloud owns iOS archives, App Store signing, and internal TestFlight
  distribution. GitHub Actions no longer builds or uploads signed iOS releases.
- `CI` now includes:
  - `Analyze`
  - `Format check`
  - `Unit tests` (placeholder-safe no-op when no `test/` suite exists yet)
  - `Web release build`
  - `Android debug build`
  - `Android e2e` (`workflow_dispatch` to run)
  - `CodeQL` security scan
  - `Dependency Review` on pull requests

## Xcode Cloud

The repository includes `ios/ci_scripts/ci_post_clone.sh` so Xcode Cloud can
install the pinned Flutter SDK, restore Dart dependencies, generate the Swift
Package Manager integration, and validate the production Firebase plist before
Xcode archives the app.

Configure the first workflow with:

- Repository: `Duvet05/nebu-mobile`
- Workspace: `ios/Runner.xcworkspace`
- Scheme: `production`
- Action: `Archive` for iOS
- Signing: automatically managed by Xcode Cloud. The post-clone hook changes
  only Xcode Cloud's temporary checkout to automatic signing.
- Start condition: manual on the `main` branch
- Internal workflow distribution preparation: `TestFlight (Internal Testing Only)`
- Internal post-action: `TestFlight Internal Testing` for `Testers Nebu`
- External workflow distribution preparation: `App Store Connect`
- External post-action: `TestFlight External Testing` for `Nebu Externos`
- Optional environment variable: `FLUTTER_VERSION=3.44.8` (the script uses this
  version by default)

The production Firebase client configuration is tracked at
`ios/firebase/production/GoogleService-Info.plist`. Firebase documents this
file as containing non-secret project and app identifiers. Do not replace it
with a Firebase Admin service-account key, APNs key, App Store Connect key, or
any other server credential.

The post-clone hook copies the tracked file into the temporary Runner target.
It temporarily retains support for the legacy single Base64 variable and the
four Xcode Cloud fragments so existing workflows remain compatible while those
obsolete variables are removed.

The post-clone script fails if the plist does not identify Firebase project
`flow-nebu-prod` and bundle ID `com.nebu.nebuMobileFlutter`.

The `Nebu iOS Production` workflow is the only automated owner of signed iOS
releases. GitHub retains shared analysis, tests, security scans, web builds, and
Android builds, but has no App Store Connect credentials or iOS publishing job.

## Web production deploy

The Flutter web production target is the JS build served from Vercel:

```sh
flutter build web --release
vercel deploy build/web --prod --archive=tgz --project nebu-mobile-web --yes
```

Release web builds default to the same-origin Vercel proxy at `/api/v1`.
Do not pass an absolute `--dart-define=API_URL=https://api.flow-telligence.com/api/v1`
for the Vercel web build unless the backend CORS allowlist has been verified.
CI runs `scripts/check-web-api-proxy.sh` after `flutter build web --release`
to catch bundles that would call the backend cross-origin from the browser.

The public production URL is:

- `https://app.flow-telligence.com`

Legacy Vercel aliases such as `https://nebu-mobile.vercel.app` should not be
treated as production until a smoke check returns `200`.

Vercel proxies `/api/v1/*` to `https://api.flow-telligence.com/api/v1/*`.
This keeps browser auth requests same-origin and avoids CORS preflight failures.
If a web build is configured to call the backend directly instead of the proxy,
backend CORS must allow every public web origin that serves this Flutter app.
For the current production backend, keep these origins in the backend
`IOT_ALLOWED_ORIGINS`/CORS allowlist:

- `https://app.flow-telligence.com`

Registration and login can pass direct API tests but still fail in the browser
when the active app origin is missing from that allowlist.

Production auth smoke checks:

```sh
curl -sS -D - -o /dev/null \
  -X POST https://app.flow-telligence.com/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  --data '{}'
```

The same-origin Vercel proxy should return a non-HTML API validation response
such as `400`/`422`, not the Flutter `index.html`.
If the app is compiled with an absolute API URL, also check direct backend CORS:

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
from that document and confirm `https://app.flow-telligence.com/setup/connection`
returns `200` after deploy.

## Branch protection

- Main is protected to require pull requests with at least one approving review and
  minimum status checks: `CI / Analyze`, `CI / Format check`, `CI / Unit tests`,
  `CI / Android debug build`.

## Store notes

- Before publishing beyond internal testing, review
  [`docs/google-play-compliance.md`](google-play-compliance.md) and update Play
  Console Data safety plus Target audience and content answers.
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
- App Store Connect requires each uploaded iOS build number (`CFBundleVersion`)
  to increase for a given app version. Keep Xcode Cloud's build-number management
  enabled and verify the generated number before promoting a build.
- The `nebu.flow-telligence.com` Apple App Site Association file must include
  the real app identifier:
  ```json
  {
    "applinks": {
      "apps": [],
      "details": [
        {
          "appID": "L7D2JCR89T.com.nebu.nebuMobileFlutter",
          "paths": ["/verify-email*", "/reset-password*"]
        }
      ]
    }
  }
  ```
  Validate this before App Store builds. A placeholder such as
  `TEAM_ID.com.nebu.nebuMobileFlutter` is not valid for universal links.
- Uploading an IPA to App Store Connect is not the same as releasing to the App
  Store. Apple processes the build first; after processing, it can be used for
  TestFlight groups or selected for App Review/release in App Store Connect.
- Keep LiveKit API keys, LiveKit API secrets, MongoDB, JWT, and OpenAI keys on
  the backend only. Do not compile those into the mobile app.

## iOS release runbook

Upload a production build to internal TestFlight:

1. Open Xcode's Report navigator and select the Cloud tab.
2. Select `Nebu iOS Production`, click `Start Build`, and choose `main`.
3. Confirm the `Archive - iOS` action and `TestFlight Internal Testing - iOS`
   post-action both finish successfully.
4. Wait for App Store Connect processing to finish. The build is assigned to
   the `Testers Nebu` internal group automatically.
5. Promote a processed build to external TestFlight or an App Store version only
   as an explicit release action. External testing may require Beta App Review.

Do not reintroduce an App Store upload job in GitHub Actions; this avoids two CI
systems competing for signing credentials and iOS build numbers.

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

## Release ownership

- Firebase, Google OAuth, and Play publishing now use the Flow-owned
  `flow-nebu-prod` project. Do not restore references to the retired PUCP
  projects or service accounts.
- Firebase has separate APNs authentication keys for the production and
  development Apple apps. Verify push delivery on a physical device after each
  credential or bundle-ID change.
- Xcode Cloud owns production archives and internal TestFlight distribution;
  GitHub CI owns Flutter analysis, tests, security checks, web builds, and
  Android builds.
