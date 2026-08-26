#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLING_DIR="${ROOT_DIR}/.tooling"
BIN_DIR="${TOOLING_DIR}/bin"
CACHE_DIR="${TOOLING_DIR}/cache"
FLUTTER_VERSION="3.47.1"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_SHA256="a1d8166c0309267cb7dc99f1424eecf08b86946ad3b50723c6f59945964aea45"

mkdir -p "${BIN_DIR}" "${CACHE_DIR}"

download() {
  local url="$1"
  local destination="$2"
  if [[ ! -f "${destination}" ]]; then
    printf '[bootstrap] Downloading %s\n' "${url}"
    curl --fail --location --retry 3 --output "${destination}" "${url}"
  fi
}

sha256_matches() {
  local expected="$1"
  local file="$2"
  local actual
  actual="$(sha256sum "${file}" | cut -d ' ' -f 1)"
  [[ "${actual}" == "${expected}" ]]
}

verify_sha256() {
  local expected="$1"
  local file="$2"
  if ! sha256_matches "${expected}" "${file}"; then
    printf 'Checksum mismatch for %s\n' "${file}" >&2
    exit 1
  fi
}

download_verified() {
  local url="$1"
  local destination="$2"
  local checksum="$3"
  download "${url}" "${destination}"
  if ! sha256_matches "${checksum}" "${destination}"; then
    # Some releases publish every version under the same file name, so a
    # cached download from an earlier pin would fail every later bump. Fetch
    # once more before treating the mismatch as a corrupt or tampered file.
    printf '[bootstrap] Replacing cached %s from an earlier pin.\n' \
      "${destination##*/}"
    rm -f "${destination}"
    download "${url}" "${destination}"
  fi
  verify_sha256 "${checksum}" "${destination}"
}

install_tar_binary() {
  local name="$1"
  local url="$2"
  local checksum="$3"
  local archive="${CACHE_DIR}/${url##*/}"
  local extract_dir="${TOOLING_DIR}/extract-${name}"
  download_verified "${url}" "${archive}" "${checksum}"
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
  download_verified "${url}" "${file}" "${checksum}"
  install -m 0755 "${file}" "${BIN_DIR}/${name}"
}

install_flutter() {
  if command -v flutter >/dev/null 2>&1 \
    && flutter --version --machine 2>/dev/null \
      | grep -q "\"frameworkVersion\":\"${FLUTTER_VERSION}\""; then
    printf '[bootstrap] Reusing Flutter %s from PATH.\n' "${FLUTTER_VERSION}"
    return
  fi
  if [[ -x "${TOOLING_DIR}/flutter/bin/flutter" ]] \
    && "${TOOLING_DIR}/flutter/bin/flutter" --version --machine \
      | grep -q "\"frameworkVersion\":\"${FLUTTER_VERSION}\""; then
    printf '[bootstrap] Reusing repository-local Flutter %s.\n' "${FLUTTER_VERSION}"
    return
  fi

  local archive="${CACHE_DIR}/${FLUTTER_ARCHIVE}"
  download_verified \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}" \
    "${archive}" \
    "${FLUTTER_SHA256}"
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
    'https://github.com/google/osv-scanner/releases/download/v2.5.1/osv-scanner_linux_amd64' \
    'f9f25499a2c8cc367b3af45df2ea7eeca7fbccceab9c35079968f4b3652194be'
  install_tar_binary \
    zizmor \
    'https://github.com/zizmorcore/zizmor/releases/download/v1.29.0/zizmor-x86_64-unknown-linux-gnu.tar.gz' \
    'dd96df044a6e8538d5f423790f453bdd03d49e5b2bcc38214acc41a2f1297839'
  install_tar_binary \
    shellcheck \
    'https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.linux.x86_64.tar.xz' \
    '8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198'
  install_tar_binary \
    syft \
    'https://github.com/anchore/syft/releases/download/v1.51.0/syft_1.51.0_linux_amd64.tar.gz' \
    '2a2e837a2c8d59ec9af5472ee22d3b04ee463c4e44476ecf993fd1e5ab6ebc7f'
  install_tar_binary \
    trivy \
    'https://github.com/aquasecurity/trivy/releases/download/v0.74.0/trivy_0.74.0_Linux-64bit.tar.gz' \
    '2ae6fe3ee734b7fdf11335663e18c75ea12dccc76062f09f164a3b0f8be4371a'
  install_raw_binary \
    cyclonedx \
    'https://github.com/CycloneDX/cyclonedx-cli/releases/download/v0.33.1/cyclonedx-linux-x64' \
    'bfc8b2538da86fe239bc53658bbb63c1c8c510a293c1e6891aa5bea5d3c58746'

  if ! command -v npm >/dev/null 2>&1; then
    printf '[bootstrap] npm is required for markdownlint-cli2.\n' >&2
    return 1
  fi
  npm install \
    --prefix "${TOOLING_DIR}/npm" \
    --no-audit \
    --no-fund \
    --save-exact \
    markdownlint-cli2@0.23.2
}

install_spdx_validator() {
  local requirements="${ROOT_DIR}/tool/sbom/requirements.txt"
  local environment="${TOOLING_DIR}/spdx-tools"
  local marker="${environment}/.requirements.sha256"
  local expected
  expected="$(sha256sum "${requirements}" | cut -d ' ' -f 1)"

  if [[ -x "${environment}/bin/pyspdxtools" ]] \
    && [[ -f "${marker}" ]] \
    && [[ "$(<"${marker}")" == "${expected}" ]]; then
    ln -sfn ../spdx-tools/bin/pyspdxtools "${BIN_DIR}/pyspdxtools"
    return
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    printf '[bootstrap] Python 3 with venv support is required for SPDX validation.\n' >&2
    return 1
  fi

  rm -rf "${environment}"
  python3 -m venv "${environment}"
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
    "${environment}/bin/pip" install \
      --no-deps \
      --require-hashes \
      --requirement "${requirements}"
  printf '%s\n' "${expected}" >"${marker}"
  ln -sfn ../spdx-tools/bin/pyspdxtools "${BIN_DIR}/pyspdxtools"
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

check_linux_audio() {
  if pkg-config --exists gstreamer-1.0 gstreamer-app-1.0; then
    return
  fi
  printf '%s\n' \
    '[bootstrap] Linux feedback audio needs GStreamer development files.' \
    '[bootstrap] Install gstreamer and gst-plugins-base (Arch/Manjaro),' \
    '[bootstrap] or libgstreamer1.0-dev and libgstreamer-plugins-base1.0-dev (Debian/Ubuntu).' >&2
  return 1
}

install_flutter
install_android_packages
install_quality_tools
install_spdx_validator
check_linux_speech
check_linux_audio

FLUTTER="${TOOLING_DIR}/flutter/bin/flutter"
if [[ ! -x "${FLUTTER}" ]]; then
  FLUTTER="$(command -v flutter)"
fi
"${FLUTTER}" config --jdk-dir="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}"
"${FLUTTER}" config --enable-android --enable-linux-desktop
"${FLUTTER}" pub get

git -C "${ROOT_DIR}" config core.hooksPath .githooks

printf '\n[bootstrap] Complete. Run ./localPipeline.sh --noRun\n'
