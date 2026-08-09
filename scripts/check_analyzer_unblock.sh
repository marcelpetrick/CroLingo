#!/usr/bin/env bash
# Watches the one upstream fact that blocks two known pieces of work.
#
# `riverpod_lint` 3.1.8 (a real Riverpod lint gate) and `drift_dev` 2.34.1+1
# (the sqlite3 3.x migration) both need `analyzer ^13.0.0`. Flutter's
# `flutter_test` pins `test_api` and `matcher`, which transitively caps the
# analyzer below 13, so neither can be resolved while those pins hold.
#
# Checking this by hand at every Flutter release is the kind of chore nobody
# performs. This reads the pins straight off Flutter's stable branch instead.
#
# Exit codes are the signal:
#   0  still blocked, nothing to do
#   1  the pins moved: re-evaluate, this is good news
#   2  the watch itself is broken, for example no network
set -Eeuo pipefail

# The values that currently block the upgrade. Update these together with the
# work they unblock, never on their own to silence the watch.
readonly BLOCKING_TEST_API="0.7.11"
readonly BLOCKING_MATCHER="0.12.19"
readonly SOURCE_URL="https://raw.githubusercontent.com/flutter/flutter/stable/packages/flutter_test/pubspec.yaml"

pubspec="$(curl -fsSL --max-time 60 "${SOURCE_URL}" 2>/dev/null)" || {
  printf 'Could not read flutter_test from the stable branch.\n' >&2
  printf 'The watch is broken, which is not the same as still blocked.\n' >&2
  exit 2
}

read_pin() {
  printf '%s\n' "${pubspec}" \
    | sed -n "s/^[[:space:]]*$1:[[:space:]]*\([0-9][^[:space:]]*\)[[:space:]]*$/\1/p" \
    | head -n 1
}

test_api="$(read_pin test_api)"
matcher="$(read_pin matcher)"

if [[ -z "${test_api}" || -z "${matcher}" ]]; then
  printf 'flutter_test no longer pins test_api and matcher the expected way.\n' >&2
  printf 'Read %s and re-evaluate by hand.\n' "${SOURCE_URL}" >&2
  exit 1
fi

printf 'Flutter stable pins test_api %s and matcher %s.\n' \
  "${test_api}" "${matcher}"

if [[ "${test_api}" == "${BLOCKING_TEST_API}" \
  && "${matcher}" == "${BLOCKING_MATCHER}" ]]; then
  printf 'Unchanged, so analyzer 13 is still out of reach. Nothing to do.\n'
  exit 0
fi

cat >&2 <<EOF

The pins moved from test_api ${BLOCKING_TEST_API} and matcher ${BLOCKING_MATCHER}.

Try the work these were blocking:
  1. riverpod_lint ^3.1.8 with 'plugins: riverpod_lint:' in analysis_options.yaml,
     replacing the lint gate that was removed for doing nothing.
  2. drift_flutter ^0.3.1, which moves to package:sqlite3 3.x and retires the
     end-of-life sqlite3_flutter_libs.

Both are described in docs/review20260809.md. A failing run here is good news.
EOF
exit 1
