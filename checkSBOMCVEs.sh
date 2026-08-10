#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${ROOT_DIR}/.tooling/trivy-cache"
REPORT_DIR="${ROOT_DIR}/build/security/trivy"
SEVERITIES="HIGH,CRITICAL"
GENERATE=true
OFFLINE=false
DOWNLOAD_ONLY=false

usage() {
  cat <<'EOF'
Usage: ./checkSBOMCVEs.sh [OPTIONS]

Generates, validates, and scans CroLingo's CycloneDX and SPDX SBOMs with the
pinned Trivy binary. The default policy fails on HIGH or CRITICAL findings.

Options:
  --existing          Scan existing build/sbom files without regenerating them.
  --offline           Use the existing local DB and make no dependency API calls.
  --download-db-only  Download/update the Trivy vulnerability DB, then exit.
  --severity LIST     Comma-separated severities (default: HIGH,CRITICAL).
  --report-dir PATH   Report destination (default: build/security/trivy).
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
if ! command -v trivy >/dev/null 2>&1; then
  "${ROOT_DIR}/scripts/bootstrap.sh"
  hash -r
fi
if ! command -v trivy >/dev/null 2>&1; then
  printf '%s\n' 'Trivy is unavailable after bootstrap.' >&2
  exit 1
fi

mkdir -p "${CACHE_DIR}"
if [[ "${DOWNLOAD_ONLY}" == true ]]; then
  if [[ "${OFFLINE}" == true ]]; then
    printf '%s\n' '--download-db-only and --offline are mutually exclusive.' >&2
    exit 2
  fi
  trivy sbom \
    --cache-dir "${CACHE_DIR}" \
    --disable-telemetry \
    --download-db-only \
    --no-progress \
    --skip-version-check
  printf 'Trivy vulnerability database is ready in %s\n' "${CACHE_DIR}"
  exit 0
fi

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
       and .Trivy.Version == "0.73.0"' "${json_report}" >/dev/null; then
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

if [[ -s "${REPORT_DIR}/cyclonedx.json" ]] \
  && [[ -s "${REPORT_DIR}/spdx.json" ]]; then
  comparison_dir="$(mktemp -d "${TMPDIR:-/tmp}/crolingo-trivy-compare.XXXXXX")"
  trap 'rm -rf "${comparison_dir}"' EXIT
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

if ((FAILURES != 0)); then
  printf 'SBOM CVE check failed with %d problem(s). Reports: %s\n' \
    "${FAILURES}" "${REPORT_DIR}" >&2
  exit 1
fi
printf 'SBOM CVE check passed. Reports: %s\n' "${REPORT_DIR}"
