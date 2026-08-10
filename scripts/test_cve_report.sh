#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="${1:-${ROOT_DIR}/build/security/cve}"
DASHBOARD="${REPORT_DIR}/dashboard.html"

"${ROOT_DIR}/generateCVEReport.sh" --report-dir "${REPORT_DIR}"
grep -Fq '<title>CroLingo security dashboard</title>' "${DASHBOARD}"
grep -Fq 'data-evaluation="pass"' "${DASHBOARD}"
grep -Eq 'data-testid="package-count">[1-9][0-9]*<' "${DASHBOARD}"
grep -Fq 'CycloneDX ↔ SPDX' "${DASHBOARD}"
if grep -Fq '<script' "${DASHBOARD}"; then
  printf '%s\n' 'The offline dashboard must not contain executable scripts.' >&2
  exit 1
fi

fixture="$(mktemp -d "${TMPDIR:-/tmp}/crolingo-cve-report-test.XXXXXX")"
trap 'rm -rf "${fixture}"' EXIT
cp "${REPORT_DIR}"/*.json "${fixture}/"
for source in \
  "${fixture}/osv-cyclonedx.json" \
  "${fixture}/osv-spdx.json"; do
  jq '.results[0].packages[0].vulnerabilities = [{
    id: "GHSA-test-<unsafe>",
    summary: "A <script>alert(1)</script> marker"
  }]' "${source}" >"${fixture}/changed.json"
  mv "${fixture}/changed.json" "${source}"
done
"${ROOT_DIR}/generateCVEReport.sh" \
  --report-dir "${fixture}" \
  --output "${fixture}/finding.html"
grep -Fq 'data-evaluation="fail"' "${fixture}/finding.html"
grep -Fq 'GHSA-test-&lt;unsafe&gt;' "${fixture}/finding.html"
if grep -Fq '<script>alert(1)</script>' "${fixture}/finding.html"; then
  printf '%s\n' 'Scanner-controlled dashboard text was not HTML-escaped.' >&2
  exit 1
fi

jq '.ArtifactType = "unexpected"' \
  "${fixture}/cyclonedx.json" >"${fixture}/invalid.json"
mv "${fixture}/invalid.json" "${fixture}/cyclonedx.json"
if "${ROOT_DIR}/generateCVEReport.sh" \
  --report-dir "${fixture}" \
  --output "${fixture}/invalid.html" \
  >/dev/null 2>&1; then
  printf '%s\n' 'The dashboard accepted an invalid scanner report.' >&2
  exit 1
fi

printf '%s\n' 'CVE dashboard summarizes clean and escaped finding reports.'
