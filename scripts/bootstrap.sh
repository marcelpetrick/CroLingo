#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLING_DIR="${ROOT_DIR}/.tooling"
BIN_DIR="${TOOLING_DIR}/bin"
CACHE_DIR="${TOOLING_DIR}/cache"
FLUTTER_VERSION="3.44.7"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_SHA256="a0edd646c159c0e816788c0e46a4f071199c1320495898f5a679599b583a05a4"

mkdir -p "${BIN_DIR}" "${CACHE_DIR}"

download() {
  local url="$1"
  local destination="$2"
  if [[ ! -f "${destination}" ]]; then
    printf '[bootstrap] Downloading %s\n' "${url}"
    curl --fail --location --retry 3 --output "${destination}" "${url}"
  fi
}

verify_sha256() {
  local expected="$1"
  local file="$2"
  local actual
  actual="$(sha256sum "${file}" | cut -d ' ' -f 1)"
  if [[ "${actual}" != "${expected}" ]]; then
    printf 'Checksum mismatch for %s\n' "${file}" >&2
    exit 1
  fi
}

install_tar_binary() {
  local name="$1"
  local url="$2"
  local checksum="$3"
  local archive="${CACHE_DIR}/${url##*/}"
  local extract_dir="${TOOLING_DIR}/extract-${name}"
  download "${url}" "${archive}"
  verify_sha256 "${checksum}" "${archive}"
  rm -rf "${extract_dir}"
  mkdir -p "${extract_dir}"
  tar -xf "${archive}" -C "${extract_dir}"
  local binary
  binary="$(find "${extract_dir}" -type f -name "${name}" -print -quit)"
  if [[ -z "${binary}" ]]; then
    printf 'Could not find %s in %s\n' "${name}" "${archive}" >&2
    exit 1
  fi
  install -m 0755 "${binary}" "${BIN_DIR}/${name}"
  rm -rf "${extract_dir}"
}

install_raw_binary() {
  local name="$1"
  local url="$2"
  local checksum="$3"
  local file="${CACHE_DIR}/${url##*/}"
  download "${url}" "${file}"
  verify_sha256 "${checksum}" "${file}"
  install -m 0755 "${file}" "${BIN_DIR}/${name}"
}

install_flutter() {
  if command -v flutter >/dev/null 2>&1 \
    && flutter --version --machine 2>/dev/null \
      | grep -q '"frameworkVersion":"3.44.7"'; then
    printf '[bootstrap] Reusing Flutter %s from PATH.\n' "${FLUTTER_VERSION}"
    return
  fi
  if [[ -x "${TOOLING_DIR}/flutter/bin/flutter" ]] \
    && "${TOOLING_DIR}/flutter/bin/flutter" --version --machine \
      | grep -q '"frameworkVersion":"3.44.7"'; then
    printf '[bootstrap] Reusing repository-local Flutter %s.\n' "${FLUTTER_VERSION}"
    return
  fi

  local archive="${CACHE_DIR}/${FLUTTER_ARCHIVE}"
  download \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}" \
    "${archive}"
  verify_sha256 "${FLUTTER_SHA256}" "${archive}"
  rm -rf "${TOOLING_DIR}/flutter"
  tar -xf "${archive}" -C "${TOOLING_DIR}"
}

install_android_packages() {
  local sdk_root="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [[ -z "${sdk_root}" && -d "/home/${USER}/Android/Sdk" ]]; then
    sdk_root="/home/${USER}/Android/Sdk"
  fi
  if [[ -z "${sdk_root}" ]]; then
    printf '[bootstrap] Android SDK not found. Install the official command-line tools, set ANDROID_HOME, and rerun.\n' >&2
    return 1
  fi
  local sdkmanager="${sdk_root}/cmdline-tools/latest/bin/sdkmanager"
  if [[ ! -x "${sdkmanager}" ]]; then
    printf '[bootstrap] sdkmanager not found below %s.\n' "${sdk_root}" >&2
    return 1
  fi
  JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}" \
    "${sdkmanager}" \
      'platform-tools' \
      'platforms;android-36' \
      'build-tools;36.0.0' \
      'ndk;28.2.13676358'
}

install_quality_tools() {
  install_tar_binary \
    actionlint \
    'https://github.com/rhysd/actionlint/releases/download/v1.7.12/actionlint_1.7.12_linux_amd64.tar.gz' \
    '8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8'
  install_tar_binary \
    gitleaks \
    'https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz' \
    '551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb'
  install_raw_binary \
    osv-scanner \
    'https://github.com/google/osv-scanner/releases/download/v2.5.0/osv-scanner_linux_amd64' \
    'edcfc41d257db36148f065055655fe3fcfc434b0b423ea67468a84c207524e0c'
  install_tar_binary \
    zizmor \
    'https://github.com/zizmorcore/zizmor/releases/download/v1.29.0/zizmor-x86_64-unknown-linux-gnu.tar.gz' \
    'dd96df044a6e8538d5f423790f453bdd03d49e5b2bcc38214acc41a2f1297839'
  install_tar_binary \
    shellcheck \
    'https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.linux.x86_64.tar.xz' \
    '8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198'

  if ! command -v npm >/dev/null 2>&1; then
    printf '[bootstrap] npm is required for markdownlint-cli2.\n' >&2
    return 1
  fi
  npm install \
    --prefix "${TOOLING_DIR}/npm" \
    --no-audit \
    --no-fund \
    --save-exact \
    markdownlint-cli2@0.22.0
}

check_linux_speech() {
  if command -v spd-say >/dev/null 2>&1 \
    || command -v espeak-ng >/dev/null 2>&1; then
    return
  fi
  printf '%s\n' \
    '[bootstrap] Optional Croatian playback needs spd-say or espeak-ng.' \
    '[bootstrap] Install espeak-ng with your system package manager.' >&2
}

install_flutter
install_android_packages
install_quality_tools
check_linux_speech

FLUTTER="${TOOLING_DIR}/flutter/bin/flutter"
if [[ ! -x "${FLUTTER}" ]]; then
  FLUTTER="$(command -v flutter)"
fi
"${FLUTTER}" config --jdk-dir="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}"
"${FLUTTER}" config --enable-android --enable-linux-desktop
"${FLUTTER}" pub get

git -C "${ROOT_DIR}" config core.hooksPath .githooks

printf '\n[bootstrap] Complete. Run ./localPipeline.sh --noRun\n'
