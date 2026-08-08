#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$#" -ne 2 ]]; then
  printf 'Usage: %s APK EXPECTED_SHA256_FILE\n' "$0" >&2
  exit 2
fi

APK="$1"
EXPECTED_FILE="$2"
if [[ ! -s "${APK}" || ! -s "${EXPECTED_FILE}" ]]; then
  printf 'APK and expected certificate fingerprint must exist.\n' >&2
  exit 1
fi

APKSIGNER="${ANDROID_HOME:-}/build-tools/36.0.0/apksigner"
if [[ ! -x "${APKSIGNER}" ]]; then
  APKSIGNER="$(command -v apksigner || true)"
fi
if [[ ! -x "${APKSIGNER}" ]]; then
  printf 'Android apksigner was not found.\n' >&2
  exit 1
fi

EXPECTED="$(tr -d '[:space:]' <"${EXPECTED_FILE}" | tr '[:upper:]' '[:lower:]')"
ACTUAL="$(${APKSIGNER} verify --print-certs "${APK}" \
  | sed -n 's/^Signer #1 certificate SHA-256 digest: //p' \
  | tr '[:upper:]' '[:lower:]')"

if [[ ! "${EXPECTED}" =~ ^[0-9a-f]{64}$ || "${ACTUAL}" != "${EXPECTED}" ]]; then
  printf 'Android signing certificate mismatch.\n' >&2
  printf 'Expected: %s\nActual:   %s\n' "${EXPECTED}" "${ACTUAL}" >&2
  exit 1
fi

printf 'Verified stable Android signing certificate: %s\n' "${ACTUAL}"
