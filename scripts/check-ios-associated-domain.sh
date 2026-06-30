#!/usr/bin/env bash
set -euo pipefail

TEAM_ID="${APP_STORE_TEAM_ID:-L7D2JCR89T}"
BUNDLE_ID="${APP_STORE_BUNDLE_ID:-com.nebu.nebuMobileFlutter}"
DOMAIN="${IOS_ASSOCIATED_DOMAIN:-nebu.flow-telligence.com}"
EXPECTED_APP_ID="${TEAM_ID}.${BUNDLE_ID}"
URL="https://${DOMAIN}/.well-known/apple-app-site-association"
AASA_CHECK_ATTEMPTS="${AASA_CHECK_ATTEMPTS:-1}"
AASA_CHECK_DELAY_SECONDS="${AASA_CHECK_DELAY_SECONDS:-10}"

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

case "${AASA_CHECK_ATTEMPTS}" in
  ''|*[!0-9]*)
    echo "AASA_CHECK_ATTEMPTS must be a positive integer" >&2
    exit 2
    ;;
esac

case "${AASA_CHECK_DELAY_SECONDS}" in
  ''|*[!0-9]*)
    echo "AASA_CHECK_DELAY_SECONDS must be a non-negative integer" >&2
    exit 2
    ;;
esac

if [ "${AASA_CHECK_ATTEMPTS}" -le 0 ]; then
  echo "AASA_CHECK_ATTEMPTS must be greater than zero" >&2
  exit 2
fi

attempt=1
while [ "${attempt}" -le "${AASA_CHECK_ATTEMPTS}" ]; do
  if curl -fsSL --max-time 20 "${URL}" -o "${tmp_file}" && ruby -rjson -e '
    path, expected = ARGV
    json = JSON.parse(File.read(path))
    details = json.dig("applinks", "details")
    abort("AASA missing applinks.details") unless details.is_a?(Array)

    match = details.any? do |entry|
      entry.is_a?(Hash) && entry["appID"] == expected
    end

    abort("AASA does not contain expected appID #{expected}") unless match
  ' "${tmp_file}" "${EXPECTED_APP_ID}"; then
    echo "AASA OK: ${EXPECTED_APP_ID}"
    exit 0
  fi

  if [ "${attempt}" -lt "${AASA_CHECK_ATTEMPTS}" ]; then
    echo "AASA check failed for ${URL} on attempt ${attempt}/${AASA_CHECK_ATTEMPTS}; retrying in ${AASA_CHECK_DELAY_SECONDS}s" >&2
    sleep "${AASA_CHECK_DELAY_SECONDS}"
  fi

  attempt=$((attempt + 1))
done

echo "AASA check failed after ${AASA_CHECK_ATTEMPTS} attempt(s): ${URL} must include ${EXPECTED_APP_ID}" >&2
exit 1
