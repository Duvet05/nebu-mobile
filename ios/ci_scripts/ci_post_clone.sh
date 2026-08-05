#!/bin/sh

# Prepare a Flutter + Swift Package Manager build for Xcode Cloud.
set -eu

REPOSITORY_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-$(cd "$(dirname "$0")/../.." && pwd)}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.44.8}"
FLUTTER_HOME="${FLUTTER_HOME:-${HOME}/flutter}"
FIREBASE_PLIST="${REPOSITORY_ROOT}/ios/Runner/GoogleService-Info.plist"

if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  git clone \
    --depth 1 \
    --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git \
    "${FLUTTER_HOME}"
fi

export PATH="${FLUTTER_HOME}/bin:${PATH}"

flutter --version
flutter config --enable-swift-package-manager
flutter precache --ios

cd "${REPOSITORY_ROOT}"

if [ -z "${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}" ]; then
  echo "Missing Xcode Cloud secret GOOGLE_SERVICE_INFO_PLIST_BASE64" >&2
  exit 1
fi

printf '%s' "${GOOGLE_SERVICE_INFO_PLIST_BASE64}" | base64 --decode > "${FIREBASE_PLIST}"
chmod 600 "${FIREBASE_PLIST}"

firebase_project_id="$(/usr/libexec/PlistBuddy -c 'Print :PROJECT_ID' "${FIREBASE_PLIST}")"
firebase_bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :BUNDLE_ID' "${FIREBASE_PLIST}")"

if [ "${firebase_project_id}" != "flow-nebu-prod" ]; then
  echo "Unexpected Firebase project in GoogleService-Info.plist" >&2
  exit 1
fi

if [ "${firebase_bundle_id}" != "com.nebu.nebuMobileFlutter" ]; then
  echo "Unexpected Firebase bundle ID in GoogleService-Info.plist" >&2
  exit 1
fi

flutter pub get
flutter build ios \
  --config-only \
  --flavor production \
  --release \
  --no-codesign \
  --dart-define=ENV=production \
  --dart-define=ENABLE_CRASH_REPORTING=true \
  --dart-define=ENABLE_DEBUG_LOGS=false \
  --dart-define=MINIMAL_IOS_RELEASE=false
