#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd -P)"

mode="debug"
google_services_json="${REPO_ROOT}/android/app/google-services.json"
google_services_explicit=false
application_id="com.nebu.mobile"
key_properties="${REPO_ROOT}/android/key.properties"
web_client_id="${GOOGLE_WEB_CLIENT_ID:-}"

usage() {
  cat <<'EOF'
Usage: check-android-google-oauth.sh [--debug | --release] [options]

Checks that google-services.json contains an Android OAuth client matching both
the application ID and the SHA-1 certificate fingerprint of the signing key,
plus the web/server OAuth client required by Google Sign-In.

Modes:
  --debug                  Check ~/.android/debug.keystore (default)
  --release                Read the upload keystore path, alias, and password
                           from android/key.properties. Google Play delivery
                           also requires the Play App Signing SHA to be
                           registered in Firebase/Google Cloud.

Options:
  --google-services PATH   google-services.json to check
  --package APPLICATION_ID Android application ID (default: com.nebu.mobile)
  --key-properties PATH    key.properties to use with --release
  --web-client-id ID       Require an exact client_type=3 OAuth client ID;
                           defaults to GOOGLE_WEB_CLIENT_ID when it is set
  -h, --help               Show this help

Debug mode can be customized with ANDROID_DEBUG_KEYSTORE,
ANDROID_DEBUG_KEY_ALIAS, and ANDROID_DEBUG_KEYSTORE_PASSWORD.
EOF
}

fail() {
  echo "Android Google OAuth check failed: $*" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --debug)
      mode="debug"
      shift
      ;;
    --release)
      mode="release"
      shift
      ;;
    --google-services)
      [ "$#" -ge 2 ] || fail "--google-services requires a path"
      google_services_json="$2"
      google_services_explicit=true
      shift 2
      ;;
    --package)
      [ "$#" -ge 2 ] || fail "--package requires an application ID"
      application_id="$2"
      shift 2
      ;;
    --key-properties)
      [ "$#" -ge 2 ] || fail "--key-properties requires a path"
      key_properties="$2"
      shift 2
      ;;
    --web-client-id)
      [ "$#" -ge 2 ] || fail "--web-client-id requires a client ID"
      [ -n "$2" ] || fail "--web-client-id cannot be empty; configure GOOGLE_WEB_CLIENT_ID"
      web_client_id="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "unknown argument: $1"
      ;;
  esac
done

debug_google_services_json="${REPO_ROOT}/android/app/src/debug/google-services.json"
if [ "${mode}" = "debug" ] &&
   [ "${google_services_explicit}" = false ] &&
   [ -f "${debug_google_services_json}" ]; then
  google_services_json="${debug_google_services_json}"
fi

command -v keytool >/dev/null 2>&1 || fail "keytool is required"
command -v python3 >/dev/null 2>&1 || fail "python3 is required"
[ -f "${google_services_json}" ] || fail "file not found: ${google_services_json}"
[ -n "${application_id}" ] || fail "application ID cannot be empty"

read_property() {
  local property_name="$1"
  local property_file="$2"
  local property_line=""

  while IFS= read -r property_line || [ -n "${property_line}" ]; do
    property_line="${property_line%$'\r'}"
    case "${property_line}" in
      "${property_name}="*)
        printf '%s' "${property_line#*=}"
        return 0
        ;;
      "${property_name}:"*)
        printf '%s' "${property_line#*:}"
        return 0
        ;;
    esac
  done < "${property_file}"

  return 1
}

if [ "${mode}" = "release" ]; then
  [ -f "${key_properties}" ] || fail "release key properties not found: ${key_properties}"

  if ! store_file="$(read_property storeFile "${key_properties}")"; then
    fail "storeFile is missing from ${key_properties}"
  fi
  if ! key_alias="$(read_property keyAlias "${key_properties}")"; then
    fail "keyAlias is missing from ${key_properties}"
  fi
  if ! store_password="$(read_property storePassword "${key_properties}")"; then
    fail "storePassword is missing from ${key_properties}"
  fi

  [ -n "${store_file}" ] || fail "storeFile is empty in ${key_properties}"
  [ -n "${key_alias}" ] || fail "keyAlias is empty in ${key_properties}"
  [ -n "${store_password}" ] || fail "storePassword is empty in ${key_properties}"

  case "${store_file}" in
    /*) keystore_path="${store_file}" ;;
    *) keystore_path="${REPO_ROOT}/android/app/${store_file}" ;;
  esac
else
  keystore_path="${ANDROID_DEBUG_KEYSTORE:-${HOME}/.android/debug.keystore}"
  key_alias="${ANDROID_DEBUG_KEY_ALIAS:-androiddebugkey}"
  store_password="${ANDROID_DEBUG_KEYSTORE_PASSWORD:-android}"
fi

[ -f "${keystore_path}" ] || fail "keystore not found: ${keystore_path}"

# keytool reads the password from its environment rather than from a command-line
# argument, keeping the secret out of logs and process arguments.
if ! certificate_sha1="$(
  KEYTOOL_STOREPASS="${store_password}" keytool -exportcert \
    -keystore "${keystore_path}" \
    -alias "${key_alias}" \
    -storepass:env KEYTOOL_STOREPASS \
    | python3 -c '
import hashlib
import sys

certificate = sys.stdin.buffer.read()
if not certificate:
    raise SystemExit("keytool returned no certificate")
print(hashlib.sha1(certificate).hexdigest().upper())
'
)"; then
  fail "could not read alias ${key_alias} from keystore ${keystore_path}"
fi

python3 - \
  "${google_services_json}" \
  "${application_id}" \
  "${certificate_sha1}" \
  "${web_client_id}" <<'PY'
import json
import re
import sys
from pathlib import Path


def fingerprint(value: str) -> str:
    return ":".join(value[index:index + 2] for index in range(0, len(value), 2))


config_path = Path(sys.argv[1])
application_id = sys.argv[2]
expected_sha1 = sys.argv[3].upper()
expected_web_client_id = sys.argv[4]

try:
    config = json.loads(config_path.read_text(encoding="utf-8"))
except (OSError, UnicodeError, json.JSONDecodeError) as error:
    print(f"Android Google OAuth check failed: cannot parse {config_path}: {error}", file=sys.stderr)
    raise SystemExit(1)

if not isinstance(config, dict):
    print(
        f"Android Google OAuth check failed: {config_path} must contain a JSON object",
        file=sys.stderr,
    )
    raise SystemExit(1)

clients = config.get("client")
if not isinstance(clients, list):
    print(
        f"Android Google OAuth check failed: {config_path} has no client list",
        file=sys.stderr,
    )
    raise SystemExit(1)


def client_package(client):
    if not isinstance(client, dict):
        return None
    client_info = client.get("client_info")
    if not isinstance(client_info, dict):
        return None
    android_client_info = client_info.get("android_client_info")
    if not isinstance(android_client_info, dict):
        return None
    return android_client_info.get("package_name")


package_clients = [
    client
    for client in clients
    if client_package(client) == application_id
]

if not package_clients:
    configured_packages = sorted(
        {
            package_name
            for client in clients
            for package_name in [client_package(client)]
            if package_name
        }
    )
    suffix = f"; configured packages: {', '.join(configured_packages)}" if configured_packages else ""
    print(
        f"Android Google OAuth check failed: {config_path} has no client for "
        f"package {application_id}{suffix}",
        file=sys.stderr,
    )
    raise SystemExit(1)

registered_sha1s = set()
web_client_ids = set()
for client in package_clients:
    oauth_clients = client.get("oauth_client", [])
    if not isinstance(oauth_clients, list):
        continue
    for oauth_client in oauth_clients:
        if not isinstance(oauth_client, dict):
            continue
        if oauth_client.get("client_type") == 3:
            client_id = oauth_client.get("client_id")
            if isinstance(client_id, str) and client_id:
                web_client_ids.add(client_id)
            continue
        if oauth_client.get("client_type") != 1:
            continue
        android_info = oauth_client.get("android_info")
        if not isinstance(android_info, dict):
            continue
        if android_info.get("package_name") != application_id:
            continue
        value = android_info.get("certificate_hash")
        if not isinstance(value, str):
            continue
        normalized = re.sub(r"[\s:-]", "", value).upper()
        if re.fullmatch(r"[0-9A-F]{40}", normalized):
            registered_sha1s.add(normalized)

if expected_sha1 not in registered_sha1s:
    registered = ", ".join(fingerprint(value) for value in sorted(registered_sha1s))
    if not registered:
        registered = "none"
    print(
        "Android Google OAuth check failed: no Android OAuth client matches "
        f"package {application_id} and signing SHA-1 {fingerprint(expected_sha1)}.",
        file=sys.stderr,
    )
    print(f"Registered SHA-1 values for this package: {registered}", file=sys.stderr)
    print(
        "Register this SHA-1 in Firebase/Google Cloud, download the refreshed "
        "google-services.json, and update GOOGLE_SERVICES_JSON_BASE64.",
        file=sys.stderr,
    )
    raise SystemExit(1)

if not web_client_ids:
    print(
        "Android Google OAuth check failed: no web/server OAuth client "
        f"(client_type=3) is configured for package {application_id}.",
        file=sys.stderr,
    )
    print(
        "Create or restore the Web OAuth client in Firebase/Google Cloud, "
        "download the refreshed google-services.json, and update "
        "GOOGLE_SERVICES_JSON_BASE64.",
        file=sys.stderr,
    )
    raise SystemExit(1)

if expected_web_client_id and expected_web_client_id not in web_client_ids:
    configured = ", ".join(sorted(web_client_ids))
    print(
        "Android Google OAuth check failed: GOOGLE_WEB_CLIENT_ID does not match "
        "any client_type=3 OAuth client in google-services.json.",
        file=sys.stderr,
    )
    print(f"Expected web client ID: {expected_web_client_id}", file=sys.stderr)
    print(f"Configured web client IDs: {configured}", file=sys.stderr)
    raise SystemExit(1)

validated_web_client_id = expected_web_client_id or sorted(web_client_ids)[0]
print(
    "Android Google OAuth configuration OK: "
    f"package={application_id}, signing SHA-1={fingerprint(expected_sha1)}, "
    f"web client ID={validated_web_client_id}"
)
PY
