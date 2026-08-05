#!/bin/sh

# Prepare a Flutter + Swift Package Manager build for Xcode Cloud.
set -eu

REPOSITORY_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-$(cd "$(dirname "$0")/../.." && pwd)}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.44.8}"
FLUTTER_HOME="${FLUTTER_HOME:-${HOME}/flutter}"
FIREBASE_PLIST="${REPOSITORY_ROOT}/ios/Runner/GoogleService-Info.plist"

retry_network_command() {
  retry_attempt=1
  retry_limit=3

  while ! "$@"; do
    if [ "${retry_attempt}" -ge "${retry_limit}" ]; then
      echo "Command failed after ${retry_limit} attempts: $*" >&2
      return 1
    fi

    retry_delay=$((retry_attempt * 10))
    echo "Network command failed; retrying in ${retry_delay}s (${retry_attempt}/${retry_limit}): $*" >&2
    sleep "${retry_delay}"
    retry_attempt=$((retry_attempt + 1))
  done
}

if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  git clone \
    --depth 1 \
    --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git \
    "${FLUTTER_HOME}"
fi

export PATH="${FLUTTER_HOME}/bin:${PATH}"

retry_network_command flutter --version
flutter config --enable-swift-package-manager
retry_network_command flutter precache --ios --force

cd "${REPOSITORY_ROOT}"

"${REPOSITORY_ROOT}/ios/ci_scripts/write_firebase_plist.sh" "${FIREBASE_PLIST}"

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

retry_network_command flutter pub get
flutter build ios \
  --config-only \
  --flavor production \
  --release \
  --no-codesign \
  --dart-define=ENV=production \
  --dart-define=ENABLE_CRASH_REPORTING=true \
  --dart-define=ENABLE_DEBUG_LOGS=false \
  --dart-define=MINIMAL_IOS_RELEASE=false

"${REPOSITORY_ROOT}/ios/ci_scripts/configure_xcode_cloud_signing.sh"
