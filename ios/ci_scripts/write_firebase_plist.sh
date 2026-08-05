#!/bin/sh

# Install the tracked Firebase client configuration. The environment-variable
# fallbacks remain temporarily so existing workflows keep working during the
# migration away from Xcode Cloud secrets.
set -eu

OUTPUT_PATH="${1:?Usage: write_firebase_plist.sh OUTPUT_PATH}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
TRACKED_PLIST="${FIREBASE_IOS_PRODUCTION_PLIST:-${SCRIPT_DIR}/../firebase/production/GoogleService-Info.plist}"
ENCODED_PLIST="${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}"

if [ -f "${TRACKED_PLIST}" ]; then
  cp "${TRACKED_PLIST}" "${OUTPUT_PATH}"
  chmod 600 "${OUTPUT_PATH}"
  exit 0
fi

if [ -z "${ENCODED_PLIST}" ]; then
  if [ -z "${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_1:-}" ] || \
     [ -z "${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_2:-}" ] || \
     [ -z "${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_3:-}" ]; then
    echo "Missing tracked Firebase plist, legacy secret, or Xcode Cloud fragments" >&2
    exit 1
  fi

  ENCODED_PLIST="${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_1}${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_2}${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_3}${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_4:-}"
fi

printf '%s' "${ENCODED_PLIST}" | base64 --decode > "${OUTPUT_PATH}"
chmod 600 "${OUTPUT_PATH}"
