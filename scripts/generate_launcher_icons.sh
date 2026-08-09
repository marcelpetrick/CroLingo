#!/usr/bin/env bash
# Regenerates the Android launcher icons from the in-app crow mascot.
#
# The generator renders the real CrowMark widget, so the launcher icon cannot
# drift from the mascot on the dashboard. It writes into
# android/app/src/main/res/mipmap-*/ and media/app_icon.png; review the diff
# and commit the results.
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

"${ROOT_DIR}/scripts/flutterw" test tool/icon/generate_launcher_icons.dart
printf '[icons] Regenerated. Review the diff before committing.\n'
