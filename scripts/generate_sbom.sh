#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-${ROOT_DIR}/build/sbom}"
GRADLE_BOM="${ROOT_DIR}/build/app/reports/cyclonedx-direct/bom.json"
VERSION="$(sed -n 's/^version: \([^+]*\)+[0-9][0-9]*$/\1/p' "${ROOT_DIR}/pubspec.yaml")"

if [[ ! "${VERSION}" =~ ^0\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Could not read a valid pre-1.0 version from pubspec.yaml.\n' >&2
  exit 1
fi
for tool in cyclonedx jq pyspdxtools syft; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    printf 'Missing SBOM tool: %s. Run ./scripts/bootstrap.sh.\n' "${tool}" >&2
    exit 1
  fi
done

working="$(mktemp -d "${TMPDIR:-/tmp}/crolingo-sbom.XXXXXX")"
trap 'rm -rf "${working}"' EXIT
mkdir -p "${OUTPUT_DIR}"
rm -f "${OUTPUT_DIR}/CroLingo.cdx.json" \
  "${OUTPUT_DIR}/CroLingo.spdx.json" \
  "${GRADLE_BOM}"

syft scan file:"${ROOT_DIR}/pubspec.lock" \
  --source-name CroLingo-Dart \
  --source-version "${VERSION}" \
  --output "cyclonedx-json=${working}/dart.cdx.json" \
  --quiet

(
  cd "${ROOT_DIR}/android"
  CROLINGO_SBOM_VERSION="${VERSION}" \
    JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}" \
    ./gradlew :app:cyclonedxDirectBom \
      --init-script "${ROOT_DIR}/tool/sbom/cyclonedx.init.gradle" \
      --no-daemon
)
if [[ ! -s "${GRADLE_BOM}" ]]; then
  printf 'Gradle did not produce its Android dependency inventory.\n' >&2
  exit 1
fi

cyclonedx merge \
  --input-files "${working}/dart.cdx.json" "${GRADLE_BOM}" \
  --output-file "${working}/merged.cdx.json" \
  --output-format json \
  --output-version v1_7

jq --arg version "${VERSION}" '
  # Syft creates heuristic CPE candidates from package names. They are useful
  # search hints but not authoritative identities, so public SBOMs retain the
  # ecosystem-native purls and remove every guessed CPE.
  .components |= map(
    del(.cpe)
    | if .properties then
        .properties |= map(select(.name != "syft:cpe23"))
      else . end
  )
  | .metadata.component = {
    "bom-ref": ("pkg:generic/CroLingo@" + $version),
    "type": "application",
    "group": "it.marcelpetrick",
    "name": "CroLingo",
    "version": $version,
    "purl": ("pkg:generic/CroLingo@" + $version),
    "licenses": [{"license": {"id": "GPL-3.0-only"}}],
    "externalReferences": [{
      "type": "vcs",
      "url": "https://github.com/marcelpetrick/CroLingo"
    }]
  }
  | .dependencies = ([{
      "ref": ("pkg:generic/CroLingo@" + $version),
      "dependsOn": ([.components[]."bom-ref"] | unique)
    }] + (.dependencies // []))
' "${working}/merged.cdx.json" >"${working}/CroLingo.cdx.json"

# Syft preserves the merged packages and dependency relationships during SPDX
# conversion. CycloneDX CLI 0.33.1 currently drops both and emits an SPDX file
# rejected by the official validator, so it is deliberately not the converter.
syft convert "${working}/CroLingo.cdx.json" \
  --output "spdx-json=${working}/converted.spdx.json" \
  --quiet

jq --arg version "${VERSION}" '
  .name = ("CroLingo-" + $version)
  | .documentNamespace = (
      "https://github.com/marcelpetrick/CroLingo/releases/tag/v"
      + $version + "/CroLingo.spdx.json"
    )
  | .documentDescribes = ["SPDXRef-CroLingo"]
  | .packages += [{
      "SPDXID": "SPDXRef-CroLingo",
      "name": "CroLingo",
      "versionInfo": $version,
      "downloadLocation": "NOASSERTION",
      "filesAnalyzed": false,
      "licenseConcluded": "GPL-3.0-only",
      "licenseDeclared": "GPL-3.0-only",
      "copyrightText": "NOASSERTION",
      "primaryPackagePurpose": "APPLICATION",
      "externalRefs": [{
        "referenceCategory": "PACKAGE-MANAGER",
        "referenceType": "purl",
        "referenceLocator": ("pkg:generic/CroLingo@" + $version)
      }]
    }]
  | .relationships += (
      [{
        "spdxElementId": "SPDXRef-DOCUMENT",
        "relationshipType": "DESCRIBES",
        "relatedSpdxElement": "SPDXRef-CroLingo"
      }]
      + [.packages[]
          | select(.SPDXID != "SPDXRef-CroLingo")
          | {
              "spdxElementId": "SPDXRef-CroLingo",
              "relationshipType": "DEPENDS_ON",
              "relatedSpdxElement": .SPDXID
            }]
    )
' "${working}/converted.spdx.json" >"${working}/CroLingo.spdx.json"

"${ROOT_DIR}/scripts/validate_sbom.sh" \
  "${working}/CroLingo.cdx.json" \
  "${working}/CroLingo.spdx.json" \
  "${VERSION}"

install -m 0644 "${working}/CroLingo.cdx.json" \
  "${OUTPUT_DIR}/CroLingo.cdx.json"
install -m 0644 "${working}/CroLingo.spdx.json" \
  "${OUTPUT_DIR}/CroLingo.spdx.json"

printf 'Generated validated CycloneDX and SPDX SBOMs in %s\n' "${OUTPUT_DIR}"
