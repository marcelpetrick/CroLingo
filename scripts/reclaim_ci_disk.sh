#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${GITHUB_ACTIONS:-}" != "true" ]]; then
  printf 'Refusing to reclaim disk outside GitHub Actions.\n' >&2
  exit 1
fi

printf 'Disk space before hosted-runner cleanup:\n'
df -h /

# Ubuntu hosted runners contain large SDKs CroLingo never uses. Keep the
# Android SDK and action tool cache intact; remove only unrelated, known paths
# on this disposable runner.
sudo rm -rf -- \
  /opt/ghc \
  /opt/hostedtoolcache/CodeQL \
  /usr/local/share/boost \
  /usr/share/dotnet

if command -v docker >/dev/null 2>&1; then
  sudo docker image prune --all --force
fi
sudo apt-get clean

printf 'Disk space after hosted-runner cleanup:\n'
df -h /
