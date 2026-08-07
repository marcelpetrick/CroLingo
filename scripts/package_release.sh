#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-${ROOT_DIR}/dist}"
VERSION="$(sed -n 's/^version: \([^+]*\)+[0-9][0-9]*$/\1/p' "${ROOT_DIR}/pubspec.yaml")"

if [[ ! "${VERSION}" =~ ^0\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Could not read a valid pre-1.0 version from pubspec.yaml.\n' >&2
  exit 1
fi

declare -A ARTIFACTS=(
  ["build/app/outputs/flutter-apk/app-release.apk"]="CroLingo-${VERSION}-universal-development.apk"
  ["build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"]="CroLingo-${VERSION}-arm64-v8a-development.apk"
  ["build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"]="CroLingo-${VERSION}-armeabi-v7a-development.apk"
  ["build/app/outputs/flutter-apk/app-x86_64-release.apk"]="CroLingo-${VERSION}-x86_64-development.apk"
  ["build/app/outputs/bundle/release/app-release.aab"]="CroLingo-${VERSION}-development.aab"
)

mkdir -p "${OUTPUT_DIR}"
for source in "${!ARTIFACTS[@]}"; do
  if [[ ! -s "${ROOT_DIR}/${source}" ]]; then
    printf 'Missing verified build: %s\n' "${source}" >&2
    exit 1
  fi
  install -m 0644 \
    "${ROOT_DIR}/${source}" \
    "${OUTPUT_DIR}/${ARTIFACTS[${source}]}"
done

LINUX_BUNDLE="${ROOT_DIR}/build/linux/x64/release/bundle"
if [[ ! -x "${LINUX_BUNDLE}/crolingo" ]]; then
  printf 'Missing verified Linux bundle: %s\n' "${LINUX_BUNDLE}" >&2
  exit 1
fi
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git -C "${ROOT_DIR}" show -s --format=%ct HEAD)}"
tar --sort=name \
  --mtime="@${SOURCE_DATE_EPOCH}" \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -cf - \
  -C "${LINUX_BUNDLE}" . \
  | gzip -n >"${OUTPUT_DIR}/CroLingo-${VERSION}-linux-x64.tar.gz"

(
  cd "${OUTPUT_DIR}"
  sha256sum CroLingo-* >SHA256SUMS.txt
)

printf 'Packaged CroLingo %s in %s\n' "${VERSION}" "${OUTPUT_DIR}"
