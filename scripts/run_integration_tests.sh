#!/usr/bin/env bash
# Runs the integration suite on a real target.
#
# These tests touch the audio plugin, system speech and an on-disk database,
# so they need a device or a desktop session. They are deliberately outside
# localPipeline.sh: a hosted runner has neither a display nor an audio device,
# and a gate that cannot run there would either be skipped silently or make
# every CI run red.
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER="${ROOT_DIR}/scripts/flutterw"
DEVICE="${1:-linux}"

cd "${ROOT_DIR}"

if [[ "${DEVICE}" == "--help" || "${DEVICE}" == "-h" ]]; then
  cat <<'EOF'
Usage: ./scripts/run_integration_tests.sh [device-id]

Runs integration_test/ on the given target. Defaults to the Linux desktop.
List targets with ./scripts/flutterw devices; pass an ADB serial to run on a
connected phone.
EOF
  exit 0
fi

if [[ "${DEVICE}" == "linux" && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  printf 'No display found; the Linux target needs a desktop session.\n' >&2
  printf 'Pass an ADB serial to run on a phone instead.\n' >&2
  exit 1
fi

printf '[integration] Target: %s\n' "${DEVICE}"
"${FLUTTER}" test integration_test -d "${DEVICE}"
