#!/bin/sh

# Decode the production Firebase plist from either the existing single secret
# or the smaller Xcode Cloud fragments used when its UI rejects long values.
set -eu

OUTPUT_PATH="${1:?Usage: write_firebase_plist.sh OUTPUT_PATH}"
ENCODED_PLIST="${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}"

if [ -z "${ENCODED_PLIST}" ]; then
  if [ -z "${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_1:-}" ] || \
     [ -z "${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_2:-}" ] || \
     [ -z "${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_3:-}" ]; then
    echo "Missing Firebase plist secret or its three Xcode Cloud fragments" >&2
    exit 1
  fi

  ENCODED_PLIST="${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_1}${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_2}${GOOGLE_SERVICE_INFO_PLIST_BASE64_PART_3}"
fi

printf '%s' "${ENCODED_PLIST}" | base64 --decode > "${OUTPUT_PATH}"
chmod 600 "${OUTPUT_PATH}"
