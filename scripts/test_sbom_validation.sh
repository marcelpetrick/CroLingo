#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(sed -n 's/^version: \([^+]*\)+[0-9][0-9]*$/\1/p' "${ROOT_DIR}/pubspec.yaml")"
CYCLONEDX_FILE="${ROOT_DIR}/build/sbom/CroLingo.cdx.json"
SPDX_FILE="${ROOT_DIR}/build/sbom/CroLingo.spdx.json"
working="$(mktemp -d "${TMPDIR:-/tmp}/crolingo-sbom-test.XXXXXX")"
trap 'rm -rf "${working}"' EXIT

jq '.specVersion = "9.9"' "${CYCLONEDX_FILE}" \
  >"${working}/invalid.cdx.json"
if "${ROOT_DIR}/scripts/validate_sbom.sh" \
  "${working}/invalid.cdx.json" "${SPDX_FILE}" "${VERSION}" \
  >/dev/null 2>&1; then
  printf 'CycloneDX validation accepted an invalid specification version.\n' >&2
  exit 1
fi

jq '.spdxVersion = "SPDX-9.9"' "${SPDX_FILE}" \
  >"${working}/invalid.spdx.json"
if "${ROOT_DIR}/scripts/validate_sbom.sh" \
  "${CYCLONEDX_FILE}" "${working}/invalid.spdx.json" "${VERSION}" \
  >/dev/null 2>&1; then
  printf 'SPDX validation accepted an invalid specification version.\n' >&2
  exit 1
fi

printf 'SBOM validators reject corrupted CycloneDX and SPDX documents.\n'
