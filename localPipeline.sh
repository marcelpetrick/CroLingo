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
course-content validation, formatting, strict analysis, framework linting,
Gradle-wrapper integrity, documentation/workflow/shell
linting, tests and coverage, Android lint, security scans, clean Linux/Android
builds, and artifact inspection. The Linux app is launched once unless --noRun
is supplied. Missing pinned tools are restored by running scripts/bootstrap.sh
automatically before the first gate. Reports are temporary unless --report-dir
is supplied, and are kept on failure so a failing run stays diagnosable.
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
  for tool in actionlint gitleaks osv-scanner shellcheck zizmor markdownlint-cli2; do
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
    .github/workflows/release.yml \
    android/gradlew \
    android/gradlew.bat \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
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
    '76805e32c009c0cf0dd5d206bddc9fb22ea42e84db904b764f3047de095493f3' \
    'android/gradle/wrapper/gradle-wrapper.jar' \
    | sha256sum --check
  grep -Fqx \
    'distributionUrl=https\://services.gradle.org/distributions/gradle-9.1.0-all.zip' \
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
  dart format --output=none --set-exit-if-changed lib test tool
}

run_analysis() {
  dart analyze --fatal-infos
}

run_custom_lint() {
  dart run custom_lint
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
run_stage "Framework lint" run_custom_lint
run_stage "Shell lint" lint_shell
run_stage "Workflow lint" lint_workflows
run_stage "Markdown lint" lint_markdown
run_stage Tests run_tests
run_stage "Android lint" run_android_lint
run_stage "Secret scan" run_secret_scan
run_stage "Vulnerability scan" run_vulnerability_scan

if ((FAILURES == 0)); then
  run_stage "Clean builds" clean_builds
  run_stage "Artifact inspection" inspect_artifacts
else
  record "Clean builds" SKIP "quality gate failed"
  record "Artifact inspection" SKIP "builds skipped"
fi

if [[ "${RUN_APP}" == true ]] && ((FAILURES == 0)); then
  run_stage "Linux launch" launch_linux
elif [[ "${RUN_APP}" == false ]]; then
  record "Linux launch" SKIP "suppressed by --noRun"
else
  record "Linux launch" SKIP "quality gate failed"
fi

finish_pipeline || exit 1
