#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="${ROOT_DIR}/build/security/cve"
OUTPUT=""

usage() {
  cat <<'EOF'
Usage: ./generateCVEReport.sh [OPTIONS]

Creates a self-contained HTML dashboard from completed CroLingo Trivy and OSV
SBOM scan reports. This presentation step never replaces the scanner exit code.

Options:
  --report-dir PATH  Directory containing the scanner JSON files.
  --output PATH      Dashboard path (default: REPORT_DIR/dashboard.html).
  -h, --help         Show this help.
EOF
}

while (($# > 0)); do
  case "$1" in
    --report-dir)
      if (($# < 2)) || [[ -z "$2" ]]; then
        printf '%s\n' '--report-dir requires a value.' >&2
        exit 2
      fi
      REPORT_DIR="$2"
      shift 2
      ;;
    --output)
      if (($# < 2)) || [[ -z "$2" ]]; then
        printf '%s\n' '--output requires a value.' >&2
        exit 2
      fi
      OUTPUT="$2"
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

if [[ ! -d "${REPORT_DIR}" ]]; then
  printf 'CVE report directory does not exist: %s\n' "${REPORT_DIR}" >&2
  exit 1
fi
REPORT_DIR="$(realpath "${REPORT_DIR}")"
if [[ -z "${OUTPUT}" ]]; then
  OUTPUT="${REPORT_DIR}/dashboard.html"
elif [[ "${OUTPUT}" != /* ]]; then
  OUTPUT="${ROOT_DIR}/${OUTPUT}"
fi

declare -A FILES=(
  [trivy_cdx]="${REPORT_DIR}/cyclonedx.json"
  [trivy_spdx]="${REPORT_DIR}/spdx.json"
  [osv_cdx]="${REPORT_DIR}/osv-cyclonedx.json"
  [osv_spdx]="${REPORT_DIR}/osv-spdx.json"
  [input_cdx]="${REPORT_DIR}/osv-input-cyclonedx.json"
  [input_spdx]="${REPORT_DIR}/osv-input-spdx.json"
  [metadata]="${REPORT_DIR}/evaluation-metadata.json"
)
for label in "${!FILES[@]}"; do
  file="${FILES[${label}]}"
  if [[ ! -s "${file}" ]] || ! jq empty "${file}" >/dev/null 2>&1; then
    printf 'Missing or invalid dashboard input %s: %s\n' \
      "${label}" "${file}" >&2
    exit 1
  fi
done

if ! jq -e '.ArtifactType == "cyclonedx" and (.Results | type == "array")' \
  "${FILES[trivy_cdx]}" >/dev/null \
  || ! jq -e '.ArtifactType == "spdx" and (.Results | type == "array")' \
    "${FILES[trivy_spdx]}" >/dev/null \
  || ! jq -e '.results | type == "array"' \
    "${FILES[osv_cdx]}" "${FILES[osv_spdx]}" >/dev/null \
  || ! jq -e '
    .schemaVersion == 1
    and (.appVersion | test("^0\\.[0-9]+\\.[0-9]+\\+[0-9]+$"))
    and (.commit | test("^[0-9a-f]{40}$"))
    and (.evaluatedAt | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T"))
    and (.sourceState == "clean" or .sourceState == "working-tree-changes")
    and (.scanMode == "online" or .scanMode == "offline")
    and (.trivySeverities | type == "string" and length > 0)
    and (.osvScannerVersion | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
  ' "${FILES[metadata]}" >/dev/null; then
  printf '%s\n' 'Scanner reports do not have the expected structures.' >&2
  exit 1
fi

read -r cdx_pub cdx_maven < <(jq -r '
  [
    ([.results[].packages[]? | select(.package.ecosystem == "Pub")] | length),
    ([.results[].packages[]? | select(.package.ecosystem == "Maven")] | length)
  ] | @tsv
' "${FILES[input_cdx]}")
read -r spdx_pub spdx_maven < <(jq -r '
  [
    ([.results[].packages[]? | select(.package.ecosystem == "Pub")] | length),
    ([.results[].packages[]? | select(.package.ecosystem == "Maven")] | length)
  ] | @tsv
' "${FILES[input_spdx]}")
if ((cdx_pub == 0 || cdx_maven == 0 || spdx_pub == 0 || spdx_maven == 0)); then
  printf '%s\n' 'Dashboard inputs must contain Pub and Maven packages.' >&2
  exit 1
fi

trivy_cdx_findings="$(jq '[.Results[]?.Vulnerabilities[]?] | length' \
  "${FILES[trivy_cdx]}")"
trivy_spdx_findings="$(jq '[.Results[]?.Vulnerabilities[]?] | length' \
  "${FILES[trivy_spdx]}")"
osv_cdx_findings="$(jq \
  '[.results[]?.packages[]?.vulnerabilities[]?] | length' \
  "${FILES[osv_cdx]}")"
osv_spdx_findings="$(jq \
  '[.results[]?.packages[]?.vulnerabilities[]?] | length' \
  "${FILES[osv_spdx]}")"

working="$(mktemp -d "${TMPDIR:-/tmp}/crolingo-cve-dashboard.XXXXXX")"
temporary=""
cleanup() {
  rm -rf "${working}"
  if [[ -n "${temporary}" ]]; then
    rm -f "${temporary}"
  fi
}
trap cleanup EXIT

normalize_inventory() {
  jq --sort-keys '[
    .results[].packages[]?.package
    | {ecosystem, name, version}
  ] | sort_by(.ecosystem, .name, .version)' "$1"
}
normalize_trivy() {
  jq --sort-keys '[
    .Results[]?.Vulnerabilities[]?
    | {
        id: .VulnerabilityID,
        installed: .InstalledVersion,
        package: .PkgName,
        severity: .Severity
      }
  ] | sort_by(.id, .package, .installed, .severity)' "$1"
}
normalize_osv() {
  jq --sort-keys '[
    .results[]?.packages[]?
    | {
        package: .package,
        vulnerabilities: ([.vulnerabilities[]?.id] | sort)
      }
  ] | sort_by(.package.ecosystem, .package.name, .package.version)' "$1"
}

normalize_inventory "${FILES[input_cdx]}" >"${working}/inventory-cdx.json"
normalize_inventory "${FILES[input_spdx]}" >"${working}/inventory-spdx.json"
normalize_trivy "${FILES[trivy_cdx]}" >"${working}/trivy-cdx.json"
normalize_trivy "${FILES[trivy_spdx]}" >"${working}/trivy-spdx.json"
normalize_osv "${FILES[osv_cdx]}" >"${working}/osv-cdx.json"
normalize_osv "${FILES[osv_spdx]}" >"${working}/osv-spdx.json"

agreement=true
for pair in inventory trivy osv; do
  if ! cmp --silent \
    "${working}/${pair}-cdx.json" "${working}/${pair}-spdx.json"; then
    agreement=false
  fi
done

trivy_affected="$(jq '[
  .Results[]?.Vulnerabilities[]?
  | [.PkgName, .InstalledVersion]
] | unique | length' "${FILES[trivy_cdx]}")"
osv_affected="$(jq '[
  .results[]?.packages[]?
  | select((.vulnerabilities // []) | length > 0)
  | [.package.ecosystem, .package.name, .package.version]
] | unique | length' "${FILES[osv_cdx]}")"

declare -A severity_counts=()
for severity in UNKNOWN LOW MEDIUM HIGH CRITICAL; do
  severity_counts[${severity}]="$(jq --arg severity "${severity}" '[
    .Results[]?.Vulnerabilities[]?
    | select((.Severity // "UNKNOWN" | ascii_upcase) == $severity)
  ] | length' "${FILES[trivy_cdx]}")"
done

total_packages=$((cdx_pub + cdx_maven))
total_signals=$((trivy_cdx_findings + osv_cdx_findings))
overall="pass"
status_title="No known policy matches"
status_detail="Both scanners completed and both SBOM formats agree."
if [[ "${agreement}" != true ]] || ((total_signals > 0)); then
  overall="fail"
  status_title="Action required"
  status_detail="Review the findings or format disagreement before release."
fi

version="$(jq -r '.appVersion' "${FILES[metadata]}")"
commit="$(jq -r '.commit[0:12]' "${FILES[metadata]}")"
generated_at="$(jq -r '.evaluatedAt' "${FILES[metadata]}")"
source_state="$(jq -r '.sourceState' "${FILES[metadata]}")"
MODE="$(jq -r '.scanMode' "${FILES[metadata]}")"
SEVERITIES="$(jq -r '.trivySeverities' "${FILES[metadata]}")"
osv_scanner_version="$(jq -r '.osvScannerVersion' "${FILES[metadata]}")"
trivy_version="$(jq -r '.Trivy.Version // "unknown"' \
  "${FILES[trivy_cdx]}")"

escape_html() {
  jq -Rnr --arg value "$1" '$value | @html'
}
version_html="$(escape_html "${version}")"
commit_html="$(escape_html "${commit}")"
generated_html="$(escape_html "${generated_at}")"
source_state_html="$(escape_html "${source_state}")"
severities_html="$(escape_html "${SEVERITIES}")"
mode_html="$(escape_html "${MODE}")"
trivy_version_html="$(escape_html "${trivy_version}")"
osv_scanner_version_html="$(escape_html "${osv_scanner_version}")"

trivy_rows="$(jq -r '
  def esc: tostring | @html;
  [
    .Results[]?.Vulnerabilities[]?
    | {
        id: (.VulnerabilityID // "Unknown"),
        package: (.PkgName // "Unknown"),
        version: (.InstalledVersion // "Unknown"),
        severity: (.Severity // "UNKNOWN" | ascii_upcase),
        fixed: (.FixedVersion // "Not listed")
      }
  ]
  | unique_by(.id, .package, .version)
  | sort_by(.severity, .package, .id)
  | .[]
  | "<tr><td><span class=\"tool tool-trivy\">Trivy</span></td>"
    + "<td><code>\(.id | esc)</code></td>"
    + "<td>\(.package | esc)<small>\(.version | esc)</small></td>"
    + "<td><span class=\"severity\">\(.severity | esc)</span></td>"
    + "<td>\(.fixed | esc)</td></tr>"
' "${FILES[trivy_cdx]}")"
osv_rows="$(jq -r '
  def esc: tostring | @html;
  [
    .results[]?.packages[]?
    | .package as $package
    | .vulnerabilities[]?
    | {
        id: (.id // "Unknown"),
        package: ($package.name // "Unknown"),
        version: ($package.version // "Unknown"),
        ecosystem: ($package.ecosystem // "Unknown")
      }
  ]
  | unique_by(.id, .ecosystem, .package, .version)
  | sort_by(.ecosystem, .package, .id)
  | .[]
  | "<tr><td><span class=\"tool tool-osv\">OSV</span></td>"
    + "<td><code>\(.id | esc)</code></td>"
    + "<td>\(.package | esc)<small>\(.ecosystem | esc) · \(.version | esc)</small></td>"
    + "<td><span class=\"severity\">ADVISORY</span></td>"
    + "<td>Review OSV advisory</td></tr>"
' "${FILES[osv_cdx]}")"
finding_rows="${trivy_rows}${osv_rows}"
if [[ -z "${finding_rows}" ]]; then
  finding_rows='<tr><td class="empty" colspan="5">No policy-matching findings in this evaluation.</td></tr>'
fi

agreement_label="Agreed"
if [[ "${agreement}" != true ]]; then
  agreement_label="Mismatch"
fi

trivy_cdx_class=""
trivy_spdx_class=""
osv_cdx_class=""
osv_spdx_class=""
if ((trivy_cdx_findings > 0)); then trivy_cdx_class="fail"; fi
if ((trivy_spdx_findings > 0)); then trivy_spdx_class="fail"; fi
if ((osv_cdx_findings > 0)); then osv_cdx_class="fail"; fi
if ((osv_spdx_findings > 0)); then osv_spdx_class="fail"; fi

output_dir="$(dirname "${OUTPUT}")"
mkdir -p "${output_dir}"
temporary="$(mktemp "${output_dir}/.crolingo-dashboard.XXXXXX")"

cat >"${temporary}" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'">
  <title>CroLingo security dashboard</title>
  <style>
    :root { color-scheme: light; --ink:#172033; --muted:#667085; --paper:#f5f7fb; --card:#fff; --red:#d8233c; --blue:#2458a6; --gold:#f4c542; --green:#12805c; --danger:#b42318; --line:#e4e7ec; }
    * { box-sizing: border-box; }
    body { margin:0; color:var(--ink); background:linear-gradient(145deg,#eef4ff 0%,var(--paper) 45%,#fff4f4 100%); font:16px/1.5 system-ui,-apple-system,"Segoe UI",sans-serif; }
    main { width:min(1120px,calc(100% - 32px)); margin:32px auto 56px; }
    header { display:flex; gap:20px; align-items:center; margin-bottom:24px; }
    .mark { width:72px; height:72px; display:grid; place-items:center; flex:0 0 auto; color:white; background:linear-gradient(135deg,var(--red) 0 49%,var(--blue) 51%); border:5px solid white; border-radius:24px; box-shadow:0 10px 30px #2458a633; font-size:34px; }
    h1,h2,p { margin-top:0; } h1 { margin-bottom:4px; font-size:clamp(1.8rem,4vw,2.7rem); letter-spacing:-.04em; } h2 { font-size:1.1rem; }
    .subtitle,.muted { color:var(--muted); } .subtitle { margin:0; }
    .hero { padding:28px; border:1px solid var(--line); border-left:8px solid var(--green); border-radius:20px; background:var(--card); box-shadow:0 16px 50px #10182810; }
    .hero.fail { border-left-color:var(--danger); }
    .status { display:inline-flex; align-items:center; gap:8px; margin-bottom:12px; padding:6px 12px; border-radius:999px; color:#fff; background:var(--green); font-size:.82rem; font-weight:800; letter-spacing:.05em; text-transform:uppercase; }
    .fail .status { background:var(--danger); }
    .grid { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:16px; margin:20px 0; }
    .card { padding:20px; border:1px solid var(--line); border-radius:16px; background:var(--card); box-shadow:0 8px 24px #1018280a; }
    .metric { display:block; margin:4px 0; font-size:2rem; font-weight:850; letter-spacing:-.04em; }
    .label { color:var(--muted); font-size:.82rem; font-weight:700; letter-spacing:.04em; text-transform:uppercase; }
    .split { display:grid; grid-template-columns:1.1fr .9fr; gap:20px; margin-top:20px; }
    .scan { display:grid; grid-template-columns:1fr auto; gap:6px 12px; padding:14px 0; border-bottom:1px solid var(--line); }
    .scan:last-child { border-bottom:0; } .scan strong { display:block; } .scan small { color:var(--muted); }
    .pill { align-self:center; padding:4px 10px; border-radius:999px; color:#067647; background:#ecfdf3; font-size:.78rem; font-weight:800; }
    .pill.fail { color:#b42318; background:#fef3f2; }
    .severity-grid { display:grid; grid-template-columns:repeat(5,1fr); gap:8px; margin-top:14px; }
    .severity-box { padding:12px 6px; text-align:center; background:#f8fafc; border-radius:12px; }
    .severity-box b { display:block; font-size:1.35rem; }
    .severity-box small { color:var(--muted); font-size:.68rem; }
    .table-wrap { overflow-x:auto; margin-top:20px; border:1px solid var(--line); border-radius:16px; background:var(--card); }
    table { width:100%; border-collapse:collapse; } caption { padding:20px; text-align:left; font-size:1.1rem; font-weight:800; }
    th,td { padding:13px 16px; border-top:1px solid var(--line); text-align:left; vertical-align:top; } th { color:var(--muted); background:#f9fafb; font-size:.75rem; text-transform:uppercase; } td small { display:block; color:var(--muted); }
    code { overflow-wrap:anywhere; } .empty { padding:32px; color:var(--green); text-align:center; font-weight:750; }
    .tool { display:inline-block; min-width:52px; padding:3px 7px; border-radius:7px; color:#fff; text-align:center; font-size:.75rem; font-weight:800; } .tool-trivy { background:var(--blue); } .tool-osv { background:var(--red); }
    .severity { font-size:.75rem; font-weight:800; }
    .facts { display:flex; flex-wrap:wrap; gap:8px 20px; margin-top:20px; color:var(--muted); font-size:.84rem; }
    .links { display:flex; flex-wrap:wrap; gap:10px; margin-top:16px; } a { color:var(--blue); font-weight:700; } .links a { padding:8px 11px; border:1px solid var(--line); border-radius:10px; background:#fff; text-decoration:none; }
    .note { margin-top:20px; padding:18px 20px; border-radius:14px; background:#fff8db; border:1px solid #f3df91; }
    footer { margin-top:24px; color:var(--muted); font-size:.82rem; }
    @media (max-width:800px) { .grid { grid-template-columns:repeat(2,1fr); } .split { grid-template-columns:1fr; } }
    @media (max-width:480px) { main { width:min(100% - 20px,1120px); margin-top:18px; } header { align-items:flex-start; } .mark { width:58px; height:58px; border-radius:18px; font-size:27px; } .grid { grid-template-columns:1fr; } .hero { padding:20px; } .severity-grid { grid-template-columns:repeat(3,1fr); } }
    @media print { body { background:white; } main { width:100%; margin:0; } .card,.hero,.table-wrap { box-shadow:none; } .links { display:none; } }
  </style>
</head>
<body data-evaluation="${overall}">
  <main>
    <header>
      <div class="mark" aria-hidden="true">🐦‍⬛</div>
      <div><h1>CroLingo security dashboard</h1><p class="subtitle">🇭🇷 Croatian learning · 🇩🇪 German guidance · SBOM vulnerability review</p></div>
    </header>
    <section class="hero ${overall}" aria-labelledby="status-title">
      <span class="status">${overall}</span>
      <h2 id="status-title">${status_title}</h2>
      <p>${status_detail}</p>
      <div class="facts"><span>Version <strong>${version_html}</strong></span><span>Commit <strong>${commit_html}</strong></span><span>Source <strong>${source_state_html}</strong></span><span>Generated <strong>${generated_html}</strong></span><span>Mode <strong>${mode_html}</strong></span></div>
    </section>
    <section class="grid" aria-label="High-level metrics">
      <article class="card"><span class="label">Resolved packages</span><span class="metric" data-testid="package-count">${total_packages}</span><span class="muted">${cdx_pub} Pub · ${cdx_maven} Maven</span></article>
      <article class="card"><span class="label">Trivy matches</span><span class="metric" data-testid="trivy-count">${trivy_cdx_findings}</span><span class="muted">${trivy_affected} affected packages</span></article>
      <article class="card"><span class="label">OSV advisories</span><span class="metric" data-testid="osv-count">${osv_cdx_findings}</span><span class="muted">${osv_affected} affected packages</span></article>
      <article class="card"><span class="label">Format agreement</span><span class="metric">${agreement_label}</span><span class="muted">CycloneDX ↔ SPDX</span></article>
    </section>
    <section class="split">
      <article class="card">
        <h2>Four independent format checks</h2>
        <div class="scan"><div><strong>Trivy · CycloneDX 1.7</strong><small>Policy: ${severities_html}</small></div><span class="pill ${trivy_cdx_class}">${trivy_cdx_findings} matches</span></div>
        <div class="scan"><div><strong>Trivy · SPDX 2.3</strong><small>Policy: ${severities_html}</small></div><span class="pill ${trivy_spdx_class}">${trivy_spdx_findings} matches</span></div>
        <div class="scan"><div><strong>OSV · CycloneDX inventory</strong><small>Every advisory blocks release</small></div><span class="pill ${osv_cdx_class}">${osv_cdx_findings} records</span></div>
        <div class="scan"><div><strong>OSV · SPDX inventory</strong><small>Every advisory blocks release</small></div><span class="pill ${osv_spdx_class}">${osv_spdx_findings} records</span></div>
      </article>
      <article class="card">
        <h2>Trivy severity profile</h2>
        <p class="muted">Only severities requested by this evaluation appear in Trivy's input reports. OSV advisories are blocked separately even without severity metadata.</p>
        <div class="severity-grid">
          <div class="severity-box"><b>${severity_counts[UNKNOWN]}</b><small>UNKNOWN</small></div>
          <div class="severity-box"><b>${severity_counts[LOW]}</b><small>LOW</small></div>
          <div class="severity-box"><b>${severity_counts[MEDIUM]}</b><small>MEDIUM</small></div>
          <div class="severity-box"><b>${severity_counts[HIGH]}</b><small>HIGH</small></div>
          <div class="severity-box"><b>${severity_counts[CRITICAL]}</b><small>CRITICAL</small></div>
        </div>
        <p class="muted">Trivy ${trivy_version_html} · OSV-Scanner ${osv_scanner_version_html}</p>
      </article>
    </section>
    <section class="table-wrap">
      <table><caption>Findings requiring review</caption><thead><tr><th>Scanner</th><th>Advisory</th><th>Package</th><th>Severity</th><th>Fix</th></tr></thead><tbody>${finding_rows}</tbody></table>
    </section>
    <aside class="note"><strong>How to read a clean result:</strong> no configured scanner matched a known advisory to the identified Pub or Maven versions at evaluation time. This is not proof that the application is free from unknown vulnerabilities, unsafe application logic, compromised build inputs, or native/runtime components absent from the SBOM.</aside>
    <nav class="links" aria-label="Raw evidence">
      <a href="cyclonedx.json">Trivy CycloneDX JSON</a><a href="spdx.json">Trivy SPDX JSON</a><a href="osv-cyclonedx.json">OSV CycloneDX JSON</a><a href="osv-spdx.json">OSV SPDX JSON</a><a href="osv-input-cyclonedx.json">Resolved OSV inventory</a><a href="evaluation-metadata.json">Evaluation metadata</a>
    </nav>
    <footer>Generated locally from validated scanner output. The dashboard contains no scripts, external assets, telemetry, or network requests.</footer>
  </main>
</body>
</html>
EOF

if [[ ! -s "${temporary}" ]] \
  || ! grep -Fq '<title>CroLingo security dashboard</title>' "${temporary}" \
  || ! grep -Fq "data-evaluation=\"${overall}\"" "${temporary}"; then
  printf '%s\n' 'Generated dashboard failed its integrity checks.' >&2
  exit 1
fi
chmod 0644 "${temporary}"
mv -f "${temporary}" "${OUTPUT}"
temporary=""
printf 'Security dashboard: %s\n' "${OUTPUT}"
