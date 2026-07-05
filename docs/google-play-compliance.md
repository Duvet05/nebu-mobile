# Google Play compliance notes

This document is an engineering checklist for the current app behavior. It is
not legal advice; the final Play Console answers must be reviewed against the
production backend, Firebase project settings, and store listing.

Sources:

- Google Play Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play Families policies: https://support.google.com/googleplay/android-developer/answer/9893335
- Android notification permission: https://developer.android.com/develop/ui/compose/notifications/notification-permission
- Firebase Cloud Messaging Flutter setup: https://firebase.google.com/docs/cloud-messaging/flutter/get-started

## Release blockers

- Complete or update Play Console > App content > Data safety before any closed,
  open, or production release.
- Complete or update Play Console > App content > Target audience and content.
- If the selected audience includes children, review Families requirements before
  release. Current app behavior includes child profiles, toys, microphone/audio,
  Bluetooth, camera, device identifiers, and location permission.
- If the app is marked as solely targeting children, current Android location
  permission is a blocker unless removed or replaced with an approved flow.
- If the app targets children and older audiences, use a neutral age screen or a
  parent-controlled flow before SDKs or features that are not approved for
  child-directed services collect data from children.
- For Bluetooth setup with a child audience, evaluate migration to Android
  Companion Device Manager for supported OS versions.
- Confirm that Firebase Cloud Messaging has APNs authentication configured for
  iOS in Firebase Console.
- Confirm that the Apple App ID and provisioning profile include Push
  Notifications. The iOS release workflow now fails when the App Store profile
  lacks `aps-environment`.

## Data Safety draft

Declare that the app collects user data. Based on current mobile code and
runtime flows, the form should include at least these categories:

- Personal info: name, email address, account/profile information.
- App activity: toy interaction logs, setup completion, usage/activity records,
  voice session metadata, error/activity events.
- App info and performance: crash logs, diagnostics, app health data.
- Device or other IDs: backend device IDs, toy/device identifiers, Firebase
  installation or messaging identifiers, FCM registration tokens.
- Audio: microphone/voice data used for real-time toy interaction.
- Photos and videos: profile image or camera/QR use if the form requires
  disclosure for image capture or upload behavior.
- Location: approximate and precise location because Android requests
  `ACCESS_COARSE_LOCATION` and `ACCESS_FINE_LOCATION`; document that this is
  for Bluetooth/Wi-Fi/device discovery and not advertising.

Current purposes to declare:

- App functionality.
- Account management.
- Personalization.
- Developer communications and service notifications.
- Security, fraud prevention, and compliance.
- Analytics / diagnostics for Crashlytics and app health.

Current sharing/processors to account for:

- Firebase Cloud Messaging: notification delivery and registration tokens.
- Firebase Crashlytics: crash diagnostics and app health.
- Google Sign-In, when the user chooses Google login.
- Apple Sign-In, when the user chooses Apple login.
- LiveKit and backend services: real-time voice/session transport and app API.
- Hosting, support, and infrastructure providers used by the backend.

Avoid declaring "no data shared" unless the final interpretation of service
providers and SDK processing has been reviewed. The privacy policy now states
that limited data is shared with service providers for core app functionality.

## Current native status

- Android declares `POST_NOTIFICATIONS`, Bluetooth permissions, location
  permissions, and network permissions.
- Android still requests location. If the app is solely child-directed, this
  must be resolved before release.
- Android Bluetooth uses direct BLE APIs today. If children are in the target
  audience, evaluate Companion Device Manager before release.
- iOS declares APNs entitlement and background modes for remote notifications.
- iOS release CI validates that the App Store provisioning profile contains
  `aps-environment`.

## Manual verification before release

1. Install a release or internal testing build on Android 13+ and verify the
   notification permission prompt appears in the app's notification flow.
2. Log in, accept notifications, and confirm `/notifications/register-device`
   receives a non-empty FCM token.
3. Send an FCM test message from Firebase Console to the device token.
4. Install an iOS TestFlight/internal build, accept notifications, and verify an
   APNs-backed FCM token is registered.
5. Force a non-fatal Crashlytics test event and confirm it appears in Firebase
   Crashlytics for Android and iOS.
6. Toggle Privacy > Analytics off, restart the app, and confirm Crashlytics
   collection remains disabled.
7. Review Play Console Data safety and Target audience answers against this
   file and the production privacy policy.
