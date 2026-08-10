#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${ROOT_DIR}/.tooling/bin:${PATH}"

for tool in cyclonedx pyspdxtools syft; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    "${ROOT_DIR}/scripts/bootstrap.sh"
    hash -r
    break
  fi
done
exec "${ROOT_DIR}/scripts/generate_sbom.sh" "$@"
