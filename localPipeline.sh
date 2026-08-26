#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLING_BIN="${ROOT_DIR}/.tooling/bin"
FLUTTER="${ROOT_DIR}/scripts/flutterw"
RUN_APP=true
LOW_DISK_BUILDS=false
REPORT_DIR=""
TEMP_REPORTS=false
FAILURES=0
declare -a SUMMARY=()

usage() {
  cat <<'EOF'
Usage: ./localPipeline.sh [--noRun] [--low-disk-builds] [--report-dir PATH]

Runs the complete CroLingo commit gate: repository policy, locked dependencies,
course-content validation, formatting, strict analysis,
Gradle-wrapper integrity, documentation/workflow/shell
linting, tests and coverage, Android lint, security scans, clean Linux/Android
builds, dual-format SBOM generation and CVE scanning, and artifact inspection.
The Linux app is launched once unless --noRun
is supplied. Missing pinned tools are restored by running scripts/bootstrap.sh
automatically before the first gate. A closing warning review names the
expected upstream warnings and lists anything unreviewed. Reports are temporary
unless --report-dir is supplied, and are kept on failure so a failing run stays
diagnosable.
Only one run may hold a worktree at a time; a second refuses immediately
rather than corrupting the shared build directory. Platform-boundary tests are
not part of this gate: run scripts/run_integration_tests.sh on a real target.
Use --low-disk-builds on constrained CI runners to discard generated Android
intermediates before the AAB build while preserving every verified artifact.
EOF
}

while (($# > 0)); do
  case "$1" in
    --noRun)
      RUN_APP=false
      shift
      ;;
    --low-disk-builds)
      LOW_DISK_BUILDS=true
      shift
      ;;
    --report-dir)
      if (($# < 2)) || [[ -z "$2" ]]; then
        printf '%s\n' '--report-dir requires a path.' >&2
        exit 2
      fi
      REPORT_DIR="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage
      exit 2
      ;;
  esac
done

cd "${ROOT_DIR}"

# Two pipelines in one worktree corrupt each other: they share build/,
# .dart_tool/ and the Gradle daemon. Hold an exclusive lock rather than
# scanning for processes, which cannot distinguish another run from the check
# that is looking for it.
exec 9>"${ROOT_DIR}/.pipeline.lock"
if ! flock -n 9; then
  printf '%s\n' 'Another pipeline already holds .pipeline.lock in this worktree.' >&2
  printf '%s\n' 'Wait for it to finish, or run from a separate git worktree.' >&2
  exit 1
fi

if [[ -z "${REPORT_DIR}" ]]; then
  REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/crolingo-pipeline.XXXXXX")"
  TEMP_REPORTS=true
else
  mkdir -p "${REPORT_DIR}"
  REPORT_DIR="$(realpath "${REPORT_DIR}")"
fi

cleanup() {
  local status="$1"
  if [[ "${TEMP_REPORTS}" != true ]]; then
    return 0
  fi
  if ((status == 0)); then
    rm -rf "${REPORT_DIR}"
  else
    printf 'Pipeline logs kept for inspection: %s\n' "${REPORT_DIR}" >&2
  fi
}
trap 'cleanup $?' EXIT

export PATH="${TOOLING_BIN}:${ROOT_DIR}/.tooling/npm/node_modules/.bin:${PATH}"
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}"
export PATH="${JAVA_HOME}/bin:${PATH}"

record() {
  local label="$1"
  local status="$2"
  local details="$3"
  SUMMARY+=("$(printf '%-24s %-4s %s' "${label}" "${status}" "${details}")")
}

run_stage() {
  local label="$1"
  shift
  local slug
  slug="$(printf '%s' "${label}" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9_-')"
  local log_path="${REPORT_DIR}/${slug}.log"
  printf '\n[PIPELINE] %s\n' "${label}"
  set +e
  (set -Eeuo pipefail; "$@") 2>&1 | tee "${log_path}"
  local status=${PIPESTATUS[0]}
  set -e
  if ((status == 0)); then
    record "${label}" PASS "completed"
  else
    record "${label}" FAIL "exit ${status}; see ${log_path}"
    FAILURES=$((FAILURES + 1))
  fi
}

report_missing_tools() {
  local missing=0
  local tool
  for tool in \
    actionlint cyclonedx gitleaks jq markdownlint-cli2 osv-scanner \
    pyspdxtools shellcheck syft trivy zizmor; do
    if ! command -v "${tool}" >/dev/null 2>&1; then
      if [[ "$1" == report ]]; then
        printf 'Missing required tool: %s\n' "${tool}" >&2
      fi
      missing=1
    fi
  done
  return "${missing}"
}

ensure_tools() {
  # A pinned tool is absent after a fresh clone or `git clean -xfd`. Bootstrap
  # is idempotent, so restore the toolchain here instead of asking a person to
  # repeat a documented command by hand.
  if ! report_missing_tools quiet; then
    printf 'Pinned tools are missing. Running ./scripts/bootstrap.sh once.\n'
    ./scripts/bootstrap.sh
    hash -r
  fi
  if ! report_missing_tools report; then
    printf 'Bootstrap did not provide every pinned tool.\n' >&2
    printf 'Install the missing system prerequisites, then rerun this pipeline.\n' >&2
    return 1
  fi
  "${FLUTTER}" --version
  java -version
  clang --version | head -n 1
  cmake --version | head -n 1
  ninja --version
}

check_repository() {
  local required
  for required in \
    docs/AGENTS.md \
    LICENSE \
    README.md \
    docs/00_product_spec.md \
    docs/01_plan.md \
    docs/02_roadmap.md \
    docs/03_questions.md \
    docs/06_sbom_plan.md \
    docs/cveCheck.md \
    .github/workflows/release.yml \
    android/gradlew \
    android/gradlew.bat \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    scripts/generate_sbom.sh \
    scripts/generate_cve_report.sh \
    scripts/test_cve_report.sh \
    scripts/test_sbom_validation.sh \
    scripts/validate_sbom.sh \
    checkSBOMCVEs.sh \
    generateCVEReport.sh \
    generateSBOM.sh \
    tool/sbom/cyclonedx.init.gradle \
    tool/sbom/requirements.in \
    tool/sbom/requirements.txt \
    pubspec.lock; do
    if [[ ! -f "${required}" ]]; then
      printf 'Required file is missing: %s\n' "${required}" >&2
      return 1
    fi
  done
  if git ls-files | grep -E '(^|/)(\.env($|\.)|local\.properties$|key\.properties$)|\.(jks|keystore|p12|pem)$' >/dev/null; then
    printf 'A prohibited secret or local configuration file is tracked.\n' >&2
    return 1
  fi
  git diff --check
}

check_gradle_wrapper() {
  if [[ ! -x android/gradlew ]]; then
    printf '%s\n' 'android/gradlew must be executable.' >&2
    return 1
  fi
  printf '%s  %s\n' \
    'b3a875ddc1f044746e1b1a55f645584505f4a10438c1afea9f15e92a7c42ec13' \
    'android/gradle/wrapper/gradle-wrapper.jar' \
    | sha256sum --check
  grep -Fqx \
    'distributionUrl=https\://services.gradle.org/distributions/gradle-9.3.1-all.zip' \
    android/gradle/wrapper/gradle-wrapper.properties
}

resolve_dependencies() {
  "${FLUTTER}" pub get --enforce-lockfile
  git diff --exit-code -- pubspec.lock
}

check_generated_sources() {
  dart run build_runner build
  git diff --exit-code -- lib/data/progress/app_database.g.dart
}

check_format() {
  dart format --output=none --set-exit-if-changed integration_test lib test tool
}

run_analysis() {
  dart analyze --fatal-infos
}

lint_shell() {
  mapfile -t files < <(find . -type f -name '*.sh' -not -path './.tooling/*' -print)
  shellcheck --severity=style "${files[@]}"
}

lint_workflows() {
  actionlint -color
  zizmor --persona=pedantic .github/workflows
}

lint_markdown() {
  markdownlint-cli2
}

run_tests() {
  "${FLUTTER}" test --coverage
  dart run tool/check_coverage.dart
  cp coverage/lcov.info "${REPORT_DIR}/lcov.info"
}

run_android_lint() {
  (
    cd android
    JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}" ./gradlew lintDebug
  )
}

run_secret_scan() {
  gitleaks git --no-banner --redact .
}

run_vulnerability_scan() {
  osv-scanner scan source -r .
}

generate_and_test_sbom() {
  ./scripts/generate_sbom.sh
  ./scripts/test_sbom_validation.sh
  mkdir -p "${REPORT_DIR}/sbom"
  cp build/sbom/CroLingo.cdx.json build/sbom/CroLingo.spdx.json \
    "${REPORT_DIR}/sbom/"
}

scan_sbom_vulnerabilities() {
  ./checkSBOMCVEs.sh \
    --existing \
    --report-dir "${REPORT_DIR}/cve"
  ./scripts/test_cve_report.sh "${REPORT_DIR}/cve"
}

clean_builds() {
  "${FLUTTER}" clean
  "${FLUTTER}" pub get --enforce-lockfile
  "${FLUTTER}" build linux --release
  "${FLUTTER}" build apk --debug
  "${FLUTTER}" build apk --release
  "${FLUTTER}" build apk --release --split-per-abi
  if [[ "${LOW_DISK_BUILDS}" == true ]]; then
    build_aab_with_reclaimed_space
  else
    "${FLUTTER}" build appbundle --release
  fi
}

build_aab_with_reclaimed_space() {
  local staging_dir
  local build_status
  staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/crolingo-artifacts.XXXXXX")"
  cp -a build/linux "${staging_dir}/linux"
  mkdir -p "${staging_dir}/flutter-apk"
  cp build/app/outputs/flutter-apk/*.apk "${staging_dir}/flutter-apk/"

  "${FLUTTER}" clean
  "${FLUTTER}" pub get --enforce-lockfile
  build_status=0
  "${FLUTTER}" build appbundle --release || build_status=$?
  if ((build_status != 0)); then
    rm -rf "${staging_dir}"
    return "${build_status}"
  fi

  mkdir -p build/app/outputs/flutter-apk
  cp "${staging_dir}/flutter-apk/"*.apk build/app/outputs/flutter-apk/
  cp -a "${staging_dir}/linux" build/linux
  rm -rf "${staging_dir}"
}

inspect_artifacts() {
  local apk="build/app/outputs/flutter-apk/app-release.apk"
  local aab="build/app/outputs/bundle/release/app-release.aab"
  local linux_app="build/linux/x64/release/bundle/crolingo"
  for artifact in "${apk}" "${aab}" "${linux_app}"; do
    if [[ ! -s "${artifact}" ]]; then
      printf 'Missing or empty artifact: %s\n' "${artifact}" >&2
      return 1
    fi
  done

  local aapt="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/home/${USER}/Android/Sdk}}/build-tools/36.0.0/aapt"
  if [[ ! -x "${aapt}" ]]; then
    printf 'aapt not found: %s\n' "${aapt}" >&2
    return 1
  fi
  local bad_permissions
  bad_permissions="$(${aapt} dump permissions "${apk}" | grep -E 'INTERNET|RECORD_AUDIO|CAMERA|LOCATION|CONTACTS|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE' || true)"
  if [[ -n "${bad_permissions}" ]]; then
    printf 'Release APK contains prohibited permissions:\n%s\n' "${bad_permissions}" >&2
    return 1
  fi
  "${aapt}" dump badging "${apk}" | tee "${REPORT_DIR}/apk-badging.txt"
}

launch_linux() {
  local executable="build/linux/x64/release/bundle/crolingo"
  set +e
  timeout 5s "${executable}" >/dev/null 2>&1
  local status=$?
  set -e
  if ((status == 0 || status == 124)); then
    return 0
  fi
  return "${status}"
}

# Warnings that originate outside this repository. CroLingo cannot remove them
# without forking a dependency or unpinning the Flutter toolchain, so they are
# named as expected instead of quietly tolerated. Delete an entry as soon as an
# upstream release retires it.
accepted_warning_reason() {
  case "$1" in
    *'Unsupported Kotlin plugin version'*)
      printf 'Gradle embeds its own Kotlin and differs from the pinned plugin'
      ;;
    *'flutter_tools/gradle/src/main/kotlin'*)
      printf "Flutter's own Gradle plugin sources, pinned with Flutter 3.47.1"
      ;;
    *"'android.builtInKotlin=false' is deprecated"* | \
      *"'android.newDsl=false' is deprecated"*)
      printf 'Flutter template flag; AGP removes it in 10.0'
      ;;
    *"Deprecated 'org.jetbrains.kotlin.android' plugin usage"*)
      printf 'Follows the Flutter template flags, also for bundled plugins'
      ;;
    *"'fun Project.android(configure: Action<BaseAppModuleExtension>): Unit' is deprecated"*)
      printf 'Flutter template keeps the legacy Android DSL until its migration lands'
      ;;
    *"'fun Project.android(configure: Action<LibraryExtension>): Unit' is deprecated"*)
      printf 'Flutter integration_test keeps the legacy Android DSL upstream'
      ;;
    *'Deprecated Gradle features were used'*)
      printf 'Aggregate notice for the deprecations listed above'
      ;;
    *'Setting the namespace via the package attribute'* | \
      *'Recommendation: remove package='* | \
      *'found in source AndroidManifest.xml'*)
      printf 'Third-party plugin manifest owned by an upstream package'
      ;;
    *'is deprecated. Deprecated in Java.'* | *'Unchecked cast of'* | \
      *'This annotation is currently applied to the value parameter only'*)
      printf 'Upstream Kotlin source of Flutter or a bundled plugin'
      ;;
    *'packages have newer versions incompatible with dependency constraints'*)
      printf 'Pins held by the Flutter SDK; upgrading is a separate decision'
      ;;
    *'Unknown keyword meta:enum'* | *'Unknown keyword deprecated'*)
      printf 'CycloneDX Gradle plugin schema-library diagnostic'
      ;;
    *'is newer than'*'language version'*)
      printf 'Analyzer version pinned by the Flutter SDK'
      ;;
    *)
      return 1
      ;;
  esac
}

# Reports only. A new warning must be judged by a person, and failing here on
# an upstream rewording would teach people to ignore this gate.
review_warnings() {
  local -a scanned=(dependencies generated-sources android-lint clean-builds sbom)
  local -A expected=()
  local -a unreviewed=()
  local name path line reason

  for name in "${scanned[@]}"; do
    path="${REPORT_DIR}/${name}.log"
    [[ -f "${path}" ]] || continue
    while IFS= read -r line; do
      if reason="$(accepted_warning_reason "${line}")"; then
        expected["${reason}"]=$((${expected["${reason}"]:-0} + 1))
      else
        unreviewed+=("${name}: ${line}")
      fi
    done < <(
      sed 's/\x1b\[[0-9;]*m//g' "${path}" \
        | grep -E '^(w: |W |WARNING: |Warning: |warning: |Unknown keyword )|Deprecated Gradle features were used|Setting the namespace via the package attribute|Recommendation: remove package=|found in source AndroidManifest.xml|packages have newer versions incompatible' \
        || true
    )
  done

  if ((${#expected[@]} > 0)); then
    printf 'Expected upstream warnings, nothing to fix in this repository:\n'
    for reason in "${!expected[@]}"; do
      printf '  %3dx %s\n' "${expected["${reason}"]}" "${reason}"
    done | sort -k2
  fi

  if ((${#unreviewed[@]} == 0)); then
    printf 'No unreviewed warnings.\n'
    return 0
  fi

  printf '\nUnreviewed warnings, decide whether they matter:\n'
  printf '  %s\n' "${unreviewed[@]}"
  printf 'This stage reports only; it never fails the pipeline.\n'
}

# Never abort the run: this report is diagnostic, and a failing pipeline is
# exactly when a missing tool must still be recorded rather than hide the
# summary.
report_version() {
  local label="$1"
  shift
  if ! "$@"; then
    printf '%s: unavailable\n' "${label}"
  fi
}

write_environment() {
  {
    printf 'commit=%s\n' "$(git rev-parse HEAD)"
    printf 'version=%s\n' "$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)"
    printf 'generated_at=%s\n' "$(date --utc +'%Y-%m-%dT%H:%M:%SZ')"
    report_version flutter "${FLUTTER}" --version
    report_version java java -version
    report_version actionlint actionlint --version
    report_version gitleaks gitleaks version
    report_version osv-scanner osv-scanner --version
    report_version shellcheck shellcheck --version
    report_version syft syft version
    report_version trivy trivy --version
    report_version cyclonedx cyclonedx --version
    report_version zizmor zizmor --version
  } >"${REPORT_DIR}/environment.txt" 2>&1
}

finish_pipeline() {
  write_environment

  {
    printf '\n========== CroLingo Pipeline Summary ==========\n'
    printf '%s\n' "${SUMMARY[@]}"
    printf '================================================\n'
  } | tee "${REPORT_DIR}/summary.txt"

  if ((FAILURES != 0)); then
    printf 'Pipeline failed with %d mandatory failing stage(s).\n' "${FAILURES}" >&2
    return 1
  fi

  printf 'Pipeline completed successfully.\n'
}

run_stage Environment ensure_tools
if ((FAILURES != 0)); then
  printf '\n%s\n' 'The environment is incomplete, so no later gate can run honestly.' >&2
  printf '%s\n' 'Automatic bootstrap could not repair it; see the message above.' >&2
  record "Remaining stages" SKIP "environment incomplete"
  finish_pipeline
  exit 1
fi

run_stage "Repository policy" check_repository
run_stage "Gradle wrapper" check_gradle_wrapper
run_stage Version dart run tool/check_version.dart
run_stage Dependencies resolve_dependencies
run_stage "Content validation" dart run tool/validate_content.dart
run_stage "Generated sources" check_generated_sources
run_stage Formatting check_format
run_stage "Dart analysis" run_analysis
run_stage "Shell lint" lint_shell
run_stage "Workflow lint" lint_workflows
run_stage "Markdown lint" lint_markdown
run_stage Tests run_tests
run_stage "Android lint" run_android_lint
run_stage "Secret scan" run_secret_scan
run_stage "Vulnerability scan" run_vulnerability_scan

if ((FAILURES == 0)); then
  run_stage "Clean builds" clean_builds
  run_stage "SBOM" generate_and_test_sbom
  if ((FAILURES == 0)); then
    run_stage "SBOM CVE scan" scan_sbom_vulnerabilities
  else
    record "SBOM CVE scan" SKIP "SBOM generation failed"
  fi
  run_stage "Artifact inspection" inspect_artifacts
else
  record "Clean builds" SKIP "quality gate failed"
  record "SBOM" SKIP "quality gate failed"
  record "SBOM CVE scan" SKIP "quality gate failed"
  record "Artifact inspection" SKIP "builds skipped"
fi

if [[ "${RUN_APP}" == true ]] && ((FAILURES == 0)); then
  run_stage "Linux launch" launch_linux
elif [[ "${RUN_APP}" == false ]]; then
  record "Linux launch" SKIP "suppressed by --noRun"
else
  record "Linux launch" SKIP "quality gate failed"
fi

run_stage "Warning review" review_warnings

finish_pipeline || exit 1
