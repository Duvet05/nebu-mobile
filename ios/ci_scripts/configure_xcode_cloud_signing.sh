#!/bin/sh

# Xcode Cloud manages signing credentials itself. Keep the repository's manual
# production settings for the existing GitHub Actions build, then switch the
# ephemeral Xcode Cloud checkout to automatic signing before Xcode archives it.
set -eu

REPOSITORY_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_FILE="${1:-${REPOSITORY_ROOT}/ios/Runner.xcodeproj/project.pbxproj}"

if [ ! -f "${PROJECT_FILE}" ]; then
  echo "Xcode project file not found: ${PROJECT_FILE}" >&2
  exit 1
fi

perl -0pi -e '
  s/CODE_SIGN_STYLE = Manual;/CODE_SIGN_STYLE = Automatic;/g;
  s/PROVISIONING_PROFILE_SPECIFIER = "[^"]*";/PROVISIONING_PROFILE_SPECIFIER = "";/g;
  s/CODE_SIGN_IDENTITY = "(?:Apple Development|Apple Distribution)";/CODE_SIGN_IDENTITY = "";/g;
  s/"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "(?:Apple Development|Apple Distribution)";/"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "";/g;
' "${PROJECT_FILE}"

if grep -Eq 'CODE_SIGN_STYLE = Manual;|PROVISIONING_PROFILE_SPECIFIER = "[^"]+";|CODE_SIGN_IDENTITY = "Apple (Development|Distribution)";|"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "Apple (Development|Distribution)";' "${PROJECT_FILE}"; then
  echo "Failed to prepare the Xcode project for Xcode Cloud automatic signing" >&2
  exit 1
fi
