#!/usr/bin/env bash
set -euo pipefail

web_dir="${1:-build/web}"
main_js="${web_dir}/main.dart.js"
vercel_config="${web_dir}/vercel.json"
prod_api_url="https://api.flow-telligence.com/api/v1"

fail() {
  printf '::error::%s\n' "$*" >&2
  exit 1
}

if [ ! -f "${main_js}" ]; then
  fail "Missing ${main_js}; run flutter build web --release first."
fi

if grep -Fq "${prod_api_url}" "${main_js}"; then
  fail "Web bundle uses ${prod_api_url}; release web builds must call same-origin /api/v1."
fi

if ! grep -Fq '"/api/v1"' "${main_js}"; then
  fail "Web bundle does not contain the same-origin /api/v1 API base URL."
fi

if [ ! -f "${vercel_config}" ]; then
  fail "Missing ${vercel_config}; web/vercel.json must be copied into build/web."
fi

if ! grep -Eq '"source"[[:space:]]*:[[:space:]]*"/api/v1/:path\*"' "${vercel_config}"; then
  fail "${vercel_config} is missing the /api/v1 Vercel rewrite source."
fi

if ! grep -Eq '"destination"[[:space:]]*:[[:space:]]*"https://api\.flow-telligence\.com/api/v1/:path\*"' "${vercel_config}"; then
  fail "${vercel_config} is missing the production API rewrite destination."
fi

for oauth_config in vercel.json "${vercel_config}"; do
  if ! grep -Eq '"Cross-Origin-Opener-Policy"[^}]*"value"[[:space:]]*:[[:space:]]*"same-origin-allow-popups"' "${oauth_config}"; then
    fail "${oauth_config} must allow Google Sign-In popup communication."
  fi
done

printf 'Web API proxy smoke passed for %s\n' "${web_dir}"
