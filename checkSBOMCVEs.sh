#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${ROOT_DIR}/.tooling/trivy-cache"
OSV_CACHE_DIR="${ROOT_DIR}/.tooling/osv-db"
REPORT_DIR="${ROOT_DIR}/build/security/cve"
SEVERITIES="HIGH,CRITICAL"
GENERATE=true
OFFLINE=false
DOWNLOAD_ONLY=false

usage() {
  cat <<'EOF'
Usage: ./checkSBOMCVEs.sh [OPTIONS]

Generates, validates, and scans CroLingo's CycloneDX and SPDX SBOMs with the
pinned Trivy and OSV-Scanner binaries. Trivy fails on HIGH or CRITICAL
findings; OSV-Scanner fails on any known advisory.

Options:
  --existing          Scan existing build/sbom files without regenerating them.
  --offline           Use the existing local DB and make no dependency API calls.
  --download-db-only  Download/update the Trivy and OSV databases, then exit.
  --severity LIST     Trivy severities (default: HIGH,CRITICAL).
  --report-dir PATH   Report destination (default: build/security/cve).
  -h, --help          Show this help.
EOF
}

while (($# > 0)); do
  case "$1" in
    --existing)
      GENERATE=false
      shift
      ;;
    --offline)
      OFFLINE=true
      shift
      ;;
    --download-db-only)
      DOWNLOAD_ONLY=true
      shift
      ;;
    --severity)
      if (($# < 2)) || [[ -z "$2" ]]; then
        printf '%s\n' '--severity requires a value.' >&2
        exit 2
      fi
      SEVERITIES="$2"
      shift 2
      ;;
    --report-dir)
      if (($# < 2)) || [[ -z "$2" ]]; then
        printf '%s\n' '--report-dir requires a path.' >&2
        exit 2
      fi
      REPORT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "${DOWNLOAD_ONLY}" == true && "${OFFLINE}" == true ]]; then
  printf '%s\n' '--download-db-only and --offline are mutually exclusive.' >&2
  exit 2
fi

IFS=',' read -r -a severity_values <<<"${SEVERITIES}"
if ((${#severity_values[@]} == 0)); then
  printf '%s\n' 'At least one severity is required.' >&2
  exit 2
fi
for severity in "${severity_values[@]}"; do
  case "${severity}" in
    UNKNOWN|LOW|MEDIUM|HIGH|CRITICAL) ;;
    *)
      printf 'Unsupported severity: %s\n' "${severity}" >&2
      exit 2
      ;;
  esac
done

export PATH="${ROOT_DIR}/.tooling/bin:${PATH}"
for tool in osv-scanner trivy; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    "${ROOT_DIR}/scripts/bootstrap.sh"
    hash -r
    break
  fi
done
for tool in osv-scanner trivy; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    printf '%s is unavailable after bootstrap.\n' "${tool}" >&2
    exit 1
  fi
done
if ! osv-scanner --version | grep -Fqx 'osv-scanner version: 2.5.1'; then
  printf '%s\n' 'Expected the repository-pinned OSV-Scanner 2.5.1.' >&2
  exit 1
fi

# The pinned OSV-Scanner still reads the OSV-Scalibr variable, while current
# upstream documentation names OSV_SCANNER_LOCAL_DB_CACHE_DIRECTORY. Export
# both to keep this pin and its eventual successor on one ignored local cache.
export OSV_SCALIBR_LOCAL_DB_CACHE_DIRECTORY="${OSV_CACHE_DIR}"
export OSV_SCANNER_LOCAL_DB_CACHE_DIRECTORY="${OSV_CACHE_DIR}"
mkdir -p "${CACHE_DIR}" "${OSV_CACHE_DIR}"

if [[ "${GENERATE}" == true ]]; then
  "${ROOT_DIR}/generateSBOM.sh"
fi

CYCLONEDX_FILE="${ROOT_DIR}/build/sbom/CroLingo.cdx.json"
SPDX_FILE="${ROOT_DIR}/build/sbom/CroLingo.spdx.json"
VERSION="$(sed -n 's/^version: \([^+]*\)+[0-9][0-9]*$/\1/p' "${ROOT_DIR}/pubspec.yaml")"
"${ROOT_DIR}/scripts/validate_sbom.sh" \
  "${CYCLONEDX_FILE}" "${SPDX_FILE}" "${VERSION}"

cdx_pub="$(jq '[.components[] | select((.purl // "") | startswith("pkg:pub/"))] | length' "${CYCLONEDX_FILE}")"
cdx_maven="$(jq '[.components[] | select((.purl // "") | startswith("pkg:maven/"))] | length' "${CYCLONEDX_FILE}")"
spdx_pub="$(jq '[.packages[].externalRefs[]? | select(.referenceType == "purl" and (.referenceLocator | startswith("pkg:pub/")))] | length' "${SPDX_FILE}")"
spdx_maven="$(jq '[.packages[].externalRefs[]? | select(.referenceType == "purl" and (.referenceLocator | startswith("pkg:maven/")))] | length' "${SPDX_FILE}")"
if ((cdx_pub == 0 || cdx_maven == 0 || spdx_pub == 0 || spdx_maven == 0)); then
  printf '%s\n' 'Both SBOMs must contain Pub and Maven PURLs before scanning.' >&2
  exit 1
fi
printf 'PURLs: CycloneDX pub=%d maven=%d; SPDX pub=%d maven=%d\n' \
  "${cdx_pub}" "${cdx_maven}" "${spdx_pub}" "${spdx_maven}"

mkdir -p "${REPORT_DIR}"
REPORT_DIR="$(realpath "${REPORT_DIR}")"
rm -f "${REPORT_DIR}/dashboard.html" \
  "${REPORT_DIR}/evaluation-metadata.json"
OSV_CYCLONEDX_INPUT="${REPORT_DIR}/osv-input-cyclonedx.json"
OSV_SPDX_INPUT="${REPORT_DIR}/osv-input-spdx.json"

# OSV-Scanner's direct SBOM extractor dropped Maven namespaces when it was
# last reviewed, in 2.5.0. Generate
# its documented intermediate inventory dynamically from each authoritative
# SBOM so `group:artifact` survives both online batch and offline matching.
jq --arg source "${CYCLONEDX_FILE}" '{
  results: [{
    source: {path: $source, type: "sbom"},
    packages: [
      .components[]
      | select((.purl // "")
          | startswith("pkg:pub/") or startswith("pkg:maven/"))
      | if (.purl | startswith("pkg:pub/")) then
          {package: {name: .name, version: .version, ecosystem: "Pub"}}
        else
          {package: {
            name: ((.group // "") + ":" + .name),
            version: .version,
            ecosystem: "Maven"
          }}
        end
    ]
  }]
}' "${CYCLONEDX_FILE}" >"${OSV_CYCLONEDX_INPUT}"

jq --arg source "${SPDX_FILE}" '{
  results: [{
    source: {path: $source, type: "sbom"},
    packages: [
      .packages[] as $package
      | $package.externalRefs[]?
      | select(.referenceType == "purl")
      | .referenceLocator as $purl
      | if ($purl | startswith("pkg:pub/")) then
          {package: {
            name: $package.name,
            version: $package.versionInfo,
            ecosystem: "Pub"
          }}
        elif ($purl | startswith("pkg:maven/")) then
          ($purl | capture(
            "^pkg:maven/(?<namespace>[^/]+)/(?<artifact>[^@]+)@"
          )) as $maven
          | {package: {
              name: ($maven.namespace + ":" + $maven.artifact),
              version: $package.versionInfo,
              ecosystem: "Maven"
            }}
        else empty
        end
    ]
  }]
}' "${SPDX_FILE}" >"${OSV_SPDX_INPUT}"

validate_osv_input() {
  local input="$1"
  local expected_pub="$2"
  local expected_maven="$3"
  jq -e \
    --argjson expected_pub "${expected_pub}" \
    --argjson expected_maven "${expected_maven}" '
      (.results | type == "array")
      and (.results | length == 1)
      and ([.results[0].packages[]
            | select(.package.ecosystem == "Pub")] | length == $expected_pub)
      and ([.results[0].packages[]
            | select(.package.ecosystem == "Maven")]
           | length == $expected_maven)
      and all(.results[0].packages[];
        (.package.name | type == "string" and length > 0)
        and (.package.version | type == "string" and length > 0))
    ' "${input}" >/dev/null
}

if ! validate_osv_input \
  "${OSV_CYCLONEDX_INPUT}" "${cdx_pub}" "${cdx_maven}" \
  || ! validate_osv_input \
    "${OSV_SPDX_INPUT}" "${spdx_pub}" "${spdx_maven}"; then
  printf '%s\n' 'Could not create complete OSV inventories from both SBOMs.' >&2
  exit 1
fi

validate_osv_report() {
  local report="$1"
  local expected_pub="$2"
  local expected_maven="$3"
  jq -e \
    --argjson expected_pub "${expected_pub}" \
    --argjson expected_maven "${expected_maven}" '
      (.results | type == "array")
      and ([.results[]? | select(.source.type == "lockfile")] | length == 1)
      and ([.results[]?.packages[]?
            | select(.package.ecosystem == "Pub")] | length == $expected_pub)
      and ([.results[]?.packages[]?
            | select(.package.ecosystem == "Maven")] | length == $expected_maven)
    ' "${report}" >/dev/null
}

if [[ "${DOWNLOAD_ONLY}" == true ]]; then
  trivy sbom \
    --cache-dir "${CACHE_DIR}" \
    --disable-telemetry \
    --download-db-only \
    --no-progress \
    --skip-version-check

  osv_download_report="$(mktemp \
    "${TMPDIR:-/tmp}/crolingo-osv-download.XXXXXX.json")"
  trap 'rm -f "${osv_download_report}"' EXIT
  set +e
  osv-scanner scan source \
    --all-packages \
    --download-offline-databases \
    --format json \
    --offline-vulnerabilities \
    --verbosity error \
    --lockfile "osv-scanner:${OSV_CYCLONEDX_INPUT}" \
    >"${osv_download_report}"
  osv_download_status=$?
  set -e
  if ((osv_download_status > 1)) \
    || ! validate_osv_report \
      "${osv_download_report}" "${cdx_pub}" "${cdx_maven}"; then
    printf '%s\n' 'OSV-Scanner could not prepare and verify its local databases.' >&2
    exit 1
  fi
  printf 'Trivy database: %s\nOSV databases: %s\n' \
    "${CACHE_DIR}" "${OSV_CACHE_DIR}"
  exit 0
fi

print_database_metadata() {
  local metadata="${CACHE_DIR}/db/metadata.json"
  if [[ -s "${metadata}" ]] && jq empty "${metadata}"; then
    printf 'Trivy DB: updated=%s downloaded=%s next-update=%s\n' \
      "$(jq -r '.UpdatedAt' "${metadata}")" \
      "$(jq -r '.DownloadedAt' "${metadata}")" \
      "$(jq -r '.NextUpdate' "${metadata}")"
  fi
}

declare -a common_args=(
  --cache-dir "${CACHE_DIR}"
  --disable-telemetry
  --no-progress
  --quiet
  --scanners vuln
  --severity "${SEVERITIES}"
  --skip-version-check
  --timeout 10m
)
if [[ "${OFFLINE}" == true ]]; then
  common_args+=(
    --offline-scan
    --skip-db-update
    --skip-java-db-update
    --skip-vex-repo-update
  )
fi

FAILURES=0
scan_sbom() {
  local label="$1"
  local source="$2"
  local slug="$3"
  local artifact_type="$4"
  local table_report="${REPORT_DIR}/${slug}.txt"
  local json_report="${REPORT_DIR}/${slug}.json"
  local table_status
  local json_status
  local findings

  # A failed scanner must never leave a previous successful report looking
  # current to a developer or artifact uploader.
  rm -f "${table_report}" "${json_report}"
  printf '\n[TRIVY] %s\n' "${label}"
  set +e
  trivy sbom "${common_args[@]}" \
    --exit-code 0 \
    --format table \
    "${source}" 2>&1 | tee "${table_report}"
  table_status=${PIPESTATUS[0]}
  trivy sbom "${common_args[@]}" \
    --exit-code 1 \
    --format json \
    --output "${json_report}" \
    "${source}"
  json_status=$?
  set -e

  if ((table_status != 0)) || [[ ! -s "${table_report}" ]] \
    || [[ ! -s "${json_report}" ]] \
    || ! jq -e --arg artifact_type "${artifact_type}" \
      '.SchemaVersion == 2
       and .ArtifactType == $artifact_type
       and (.Results | type == "array")
       and .Trivy.Version == "0.74.0"' "${json_report}" >/dev/null; then
    printf 'Trivy could not produce valid %s reports.\n' "${label}" >&2
    FAILURES=$((FAILURES + 1))
    return
  fi
  findings="$(jq '[.Results[]?.Vulnerabilities[]?] | length' "${json_report}")"
  if ((findings > 0)); then
    printf '%s has %d %s vulnerability finding(s).\n' \
      "${label}" "${findings}" "${SEVERITIES}" >&2
    FAILURES=$((FAILURES + 1))
  elif ((json_status != 0)); then
    printf 'Trivy failed operationally while scanning %s.\n' "${label}" >&2
    FAILURES=$((FAILURES + 1))
  else
    printf '%s has no known %s vulnerability.\n' \
      "${label}" "${SEVERITIES}"
  fi
}

scan_sbom "CycloneDX 1.7" "${CYCLONEDX_FILE}" "cyclonedx" "cyclonedx"
scan_sbom "SPDX 2.3" "${SPDX_FILE}" "spdx" "spdx"
print_database_metadata

normalize_findings() {
  jq --sort-keys '[
    .Results[]?.Vulnerabilities[]?
    | {
        id: .VulnerabilityID,
        installed: .InstalledVersion,
        package: .PkgName,
        purl: (.PkgIdentifier.PURL // ""),
        severity: .Severity,
        status: (.Status // "")
      }
  ] | sort_by(.id, .purl, .package, .installed, .severity, .status)' "$1"
}

comparison_dir="$(mktemp -d \
  "${TMPDIR:-/tmp}/crolingo-cve-compare.XXXXXX")"
trap 'rm -rf "${comparison_dir}"' EXIT
if [[ -s "${REPORT_DIR}/cyclonedx.json" ]] \
  && [[ -s "${REPORT_DIR}/spdx.json" ]]; then
  normalize_findings "${REPORT_DIR}/cyclonedx.json" \
    >"${comparison_dir}/cyclonedx.json"
  normalize_findings "${REPORT_DIR}/spdx.json" \
    >"${comparison_dir}/spdx.json"
  if ! cmp --silent \
    "${comparison_dir}/cyclonedx.json" "${comparison_dir}/spdx.json"; then
    printf '%s\n' 'CycloneDX and SPDX produced different Trivy findings.' >&2
    diff --unified \
      "${comparison_dir}/cyclonedx.json" "${comparison_dir}/spdx.json" \
      || true
    FAILURES=$((FAILURES + 1))
  else
    printf '%s\n' 'CycloneDX and SPDX findings are equivalent.'
  fi
fi

declare -a osv_args=(
  scan source
  --all-packages
  --verbosity error
)
if [[ "${OFFLINE}" == true ]]; then
  osv_args+=(--offline)
fi

scan_osv_sbom() {
  local label="$1"
  local source="$2"
  local slug="$3"
  local expected_pub="$4"
  local expected_maven="$5"
  local table_report="${REPORT_DIR}/osv-${slug}.txt"
  local json_report="${REPORT_DIR}/osv-${slug}.json"
  local table_status
  local json_status
  local findings

  rm -f "${table_report}" "${json_report}"
  printf '\n[OSV] %s\n' "${label}"
  set +e
  osv-scanner "${osv_args[@]}" \
    --format table \
    --lockfile "osv-scanner:${source}" \
    2>&1 | tee "${table_report}"
  table_status=${PIPESTATUS[0]}
  osv-scanner "${osv_args[@]}" \
    --format json \
    --lockfile "osv-scanner:${source}" \
    >"${json_report}"
  json_status=$?
  set -e

  if [[ ! -s "${table_report}" ]] || [[ ! -s "${json_report}" ]] \
    || ! validate_osv_report \
      "${json_report}" "${expected_pub}" "${expected_maven}"; then
    printf 'OSV-Scanner could not produce valid %s reports.\n' \
      "${label}" >&2
    FAILURES=$((FAILURES + 1))
    return
  fi

  findings="$(jq \
    '[.results[]?.packages[]?.vulnerabilities[]?] | length' \
    "${json_report}")"
  if ((findings > 0)); then
    if ((table_status != 1 || json_status != 1)); then
      printf 'OSV-Scanner returned inconsistent finding statuses for %s.\n' \
        "${label}" >&2
    else
      printf '%s has %d OSV vulnerability record(s).\n' \
        "${label}" "${findings}" >&2
    fi
    FAILURES=$((FAILURES + 1))
  elif ((table_status != 0 || json_status != 0)); then
    printf 'OSV-Scanner failed operationally while scanning %s.\n' \
      "${label}" >&2
    FAILURES=$((FAILURES + 1))
  else
    printf '%s has no known OSV vulnerability.\n' "${label}"
  fi
}

scan_osv_sbom \
  "CycloneDX 1.7" "${OSV_CYCLONEDX_INPUT}" "cyclonedx" \
  "${cdx_pub}" "${cdx_maven}"
scan_osv_sbom \
  "SPDX 2.3" "${OSV_SPDX_INPUT}" "spdx" \
  "${spdx_pub}" "${spdx_maven}"

normalize_osv_result() {
  jq --sort-keys '[
    .results[]?.packages[]?
    | select(.package.ecosystem == "Pub" or .package.ecosystem == "Maven")
    | {
        ecosystem: .package.ecosystem,
        name: .package.name,
        version: .package.version,
        vulnerabilities: ([.vulnerabilities[]?.id] | sort)
      }
  ] | sort_by(.ecosystem, .name, .version)' "$1"
}

if [[ -s "${REPORT_DIR}/osv-cyclonedx.json" ]] \
  && [[ -s "${REPORT_DIR}/osv-spdx.json" ]]; then
  normalize_osv_result "${REPORT_DIR}/osv-cyclonedx.json" \
    >"${comparison_dir}/osv-cyclonedx.json"
  normalize_osv_result "${REPORT_DIR}/osv-spdx.json" \
    >"${comparison_dir}/osv-spdx.json"
  if ! cmp --silent \
    "${comparison_dir}/osv-cyclonedx.json" \
    "${comparison_dir}/osv-spdx.json"; then
    printf '%s\n' \
      'CycloneDX and SPDX produced different OSV inventories or findings.' >&2
    diff --unified \
      "${comparison_dir}/osv-cyclonedx.json" \
      "${comparison_dir}/osv-spdx.json" || true
    FAILURES=$((FAILURES + 1))
  else
    printf '%s\n' 'CycloneDX and SPDX OSV inventories and findings agree.'
  fi
fi

scan_mode="online"
if [[ "${OFFLINE}" == true ]]; then
  scan_mode="offline"
fi
full_version="$(sed -n 's/^version: \([^[:space:]]*\)$/\1/p' \
  "${ROOT_DIR}/pubspec.yaml")"
source_state="clean"
if [[ -n "$(git -C "${ROOT_DIR}" status --porcelain=v1)" ]]; then
  source_state="working-tree-changes"
fi
metadata_temporary="$(mktemp \
  "${REPORT_DIR}/.evaluation-metadata.XXXXXX")"
jq -n \
  --arg app_version "${full_version}" \
  --arg commit "$(git -C "${ROOT_DIR}" rev-parse HEAD)" \
  --arg evaluated_at "$(date --utc +'%Y-%m-%dT%H:%M:%SZ')" \
  --arg source_state "${source_state}" \
  --arg scan_mode "${scan_mode}" \
  --arg trivy_severities "${SEVERITIES}" \
  --arg osv_scanner_version "$(osv-scanner --version | sed -n 's/^osv-scanner version: //p')" \
  '{
    schemaVersion: 1,
    appVersion: $app_version,
    commit: $commit,
    evaluatedAt: $evaluated_at,
    sourceState: $source_state,
    scanMode: $scan_mode,
    trivySeverities: $trivy_severities,
    osvScannerVersion: $osv_scanner_version
  }' >"${metadata_temporary}"
chmod 0644 "${metadata_temporary}"
mv -f "${metadata_temporary}" \
  "${REPORT_DIR}/evaluation-metadata.json"
if ! "${ROOT_DIR}/scripts/generate_cve_report.sh" \
  --report-dir "${REPORT_DIR}"; then
  printf '%s\n' 'Could not generate the human-readable CVE dashboard.' >&2
  FAILURES=$((FAILURES + 1))
fi

if ((FAILURES != 0)); then
  printf 'SBOM CVE check failed with %d problem(s). Reports: %s\n' \
    "${FAILURES}" "${REPORT_DIR}" >&2
  exit 1
fi
printf 'Trivy and OSV SBOM checks passed. Reports: %s\n' "${REPORT_DIR}"
