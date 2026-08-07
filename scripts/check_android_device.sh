#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-${HOME}/Android/Sdk}}"
ADB="${ANDROID_SDK}/platform-tools/adb"
SERIAL=""
INSTALL=false
APK="${ROOT_DIR}/build/app/outputs/flutter-apk/app-debug.apk"

usage() {
  cat <<'EOF'
Usage: ./scripts/check_android_device.sh [--serial ID] [--install] [--apk PATH]

Reads compatibility and security-relevant properties from one authorized
Android device. With --install, builds or installs a development APK and starts
CroLingo. No data is removed and release signing material is never used.
EOF
}

while (($# > 0)); do
  case "$1" in
    --serial)
      if (($# < 2)) || [[ -z "$2" ]]; then
        printf '%s\n' '--serial requires a device ID.' >&2
        exit 2
      fi
      SERIAL="$2"
      shift 2
      ;;
    --install)
      INSTALL=true
      shift
      ;;
    --apk)
      if (($# < 2)) || [[ -z "$2" ]]; then
        printf '%s\n' '--apk requires a file path.' >&2
        exit 2
      fi
      APK="$2"
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

if [[ ! -x "${ADB}" ]]; then
  printf 'adb not found at %s. Run ./scripts/bootstrap.sh first.\n' "${ADB}" >&2
  exit 1
fi

if [[ -z "${SERIAL}" ]]; then
  mapfile -t DEVICES < <("${ADB}" devices | awk 'NR > 1 && $2 == "device" {print $1}')
  if ((${#DEVICES[@]} != 1)); then
    printf 'Expected one authorized device, found %d. Use --serial ID.\n' \
      "${#DEVICES[@]}" >&2
    "${ADB}" devices -l
    exit 1
  fi
  SERIAL="${DEVICES[0]}"
fi

ADB_DEVICE=("${ADB}" -s "${SERIAL}")
if [[ "$("${ADB_DEVICE[@]}" get-state 2>/dev/null)" != "device" ]]; then
  printf 'Device %s is not connected and authorized.\n' "${SERIAL}" >&2
  exit 1
fi

property() {
  "${ADB_DEVICE[@]}" shell getprop "$1" | tr -d '\r'
}

MODEL="$(property ro.product.model)"
MANUFACTURER="$(property ro.product.manufacturer)"
API_LEVEL="$(property ro.build.version.sdk)"
ANDROID_RELEASE="$(property ro.build.version.release)"
SECURITY_PATCH="$(property ro.build.version.security_patch)"
ABI="$(property ro.product.cpu.abi)"

printf 'Device: %s %s (%s)\n' "${MANUFACTURER}" "${MODEL}" "${SERIAL}"
printf 'Android: %s (API %s)\n' "${ANDROID_RELEASE}" "${API_LEVEL}"
printf 'Security patch: %s\n' "${SECURITY_PATCH:-unknown}"
printf 'Primary ABI: %s\n' "${ABI}"

if [[ ! "${API_LEVEL}" =~ ^[0-9]+$ ]] || ((API_LEVEL < 24)); then
  printf 'Unsupported Android API: CroLingo requires API 24 or newer.\n' >&2
  exit 1
fi
case "${ABI}" in
  arm64-v8a|armeabi-v7a|x86_64) ;;
  *)
    printf 'Unsupported primary ABI: %s\n' "${ABI}" >&2
    exit 1
    ;;
esac

if [[ -n "${SECURITY_PATCH}" ]]; then
  printf '%s\n' \
    'Note: device OS patch status is shown for awareness; CroLingo cannot update it.'
fi

if [[ "${INSTALL}" != true ]]; then
  printf '%s\n' 'Compatibility checks passed. Add --install to install and launch.'
  exit 0
fi

if [[ ! -f "${APK}" ]]; then
  if [[ "${APK}" != "${ROOT_DIR}/build/app/outputs/flutter-apk/app-debug.apk" ]]; then
    printf 'APK does not exist: %s\n' "${APK}" >&2
    exit 1
  fi
  "${ROOT_DIR}/scripts/flutterw" build apk --debug
fi

"${ADB_DEVICE[@]}" install -r "${APK}"
"${ADB_DEVICE[@]}" shell am start \
  -n it.marcelpetrick.crolingo/.MainActivity >/dev/null
sleep 2
if [[ -z "$("${ADB_DEVICE[@]}" shell pidof it.marcelpetrick.crolingo | tr -d '\r')" ]]; then
  printf '%s\n' 'CroLingo did not remain running after launch.' >&2
  exit 1
fi
printf '%s\n' 'CroLingo installed and launched. Complete the checklist in docs/01_plan.md.'
