#!/usr/bin/env bash
set -euo pipefail

TEAM_ID="${APP_STORE_TEAM_ID:-L7D2JCR89T}"
BUNDLE_ID="${APP_STORE_BUNDLE_ID:-com.nebu.nebuMobileFlutter}"
DOMAIN="${IOS_ASSOCIATED_DOMAIN:-nebu.flow-telligence.com}"
EXPECTED_APP_ID="${TEAM_ID}.${BUNDLE_ID}"
URL="https://${DOMAIN}/.well-known/apple-app-site-association"

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

curl -fsSL --max-time 20 "${URL}" -o "${tmp_file}"

ruby -rjson -e '
  path, expected = ARGV
  json = JSON.parse(File.read(path))
  details = json.dig("applinks", "details")
  abort("AASA missing applinks.details") unless details.is_a?(Array)

  match = details.any? do |entry|
    entry.is_a?(Hash) && entry["appID"] == expected
  end

  abort("AASA does not contain expected appID #{expected}") unless match
' "${tmp_file}" "${EXPECTED_APP_ID}"

echo "AASA OK: ${EXPECTED_APP_ID}"
