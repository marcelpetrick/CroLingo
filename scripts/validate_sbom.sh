#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if (($# != 3)); then
  printf 'Usage: %s CYCLONEDX_JSON SPDX_JSON VERSION\n' "${0##*/}" >&2
  exit 2
fi
CYCLONEDX_FILE="$1"
SPDX_FILE="$2"
VERSION="$3"

# The release workflow calls this through package_release.sh, outside the
# pipeline that exports the pinned toolchain. Find the tools here so every
# caller validates with the same bootstrapped versions.
export PATH="${ROOT_DIR}/.tooling/bin:${PATH}"
for tool in cyclonedx jq pyspdxtools; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    printf 'Missing SBOM tool: %s. Run ./scripts/bootstrap.sh.\n' "${tool}" >&2
    exit 1
  fi
done

for file in "${CYCLONEDX_FILE}" "${SPDX_FILE}"; do
  if [[ ! -s "${file}" ]]; then
    printf 'Missing or empty SBOM: %s\n' "${file}" >&2
    exit 1
  fi
  jq empty "${file}"
done

cyclonedx validate \
  --input-file "${CYCLONEDX_FILE}" \
  --input-format json \
  --input-version v1_7 \
  --fail-on-errors
pyspdxtools --infile "${SPDX_FILE}"

jq --exit-status --arg version "${VERSION}" '
  .bomFormat == "CycloneDX"
  and .specVersion == "1.7"
  and .metadata.component.name == "CroLingo"
  and .metadata.component.version == $version
  and any(.components[]; (.purl // "") | startswith("pkg:pub/"))
  and any(.components[]; (.purl // "") | startswith("pkg:maven/"))
  and any(.components[]; .name == "flutter_riverpod")
  and any(.dependencies[]; .ref == ("pkg:generic/CroLingo@" + $version))
  and all(.components[]; has("cpe") | not)
  and all(.components[].properties[]?; .name != "syft:cpe23")
' "${CYCLONEDX_FILE}" >/dev/null

jq --exit-status --arg version "${VERSION}" '
  .spdxVersion == "SPDX-2.3"
  and .name == ("CroLingo-" + $version)
  and .documentDescribes == ["SPDXRef-CroLingo"]
  and any(.packages[];
    .SPDXID == "SPDXRef-CroLingo"
    and .versionInfo == $version
    and .licenseDeclared == "GPL-3.0-only")
  and any(.packages[].externalRefs[]?;
    .referenceType == "purl"
    and (.referenceLocator | startswith("pkg:pub/")))
  and any(.packages[].externalRefs[]?;
    .referenceType == "purl"
    and (.referenceLocator | startswith("pkg:maven/")))
  and all(.packages[].externalRefs[]?;
    (.referenceType | test("cpe"; "i")) | not)
' "${SPDX_FILE}" >/dev/null

printf 'Validated CycloneDX 1.7 (%s components) and SPDX 2.3 (%s packages).\n' \
  "$(jq '.components | length' "${CYCLONEDX_FILE}")" \
  "$(jq '.packages | length' "${SPDX_FILE}")"
