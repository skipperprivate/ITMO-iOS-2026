#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
VERSION=0.65.1
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
curl --fail --location "https://github.com/realm/SwiftLint/releases/download/$VERSION/portable_swiftlint.zip" -o "$TEMP_DIR/swiftlint.zip"
mkdir -p "$ROOT/.tools/swiftlint"
unzip -o -q "$TEMP_DIR/swiftlint.zip" -d "$ROOT/.tools/swiftlint"
chmod +x "$ROOT/.tools/swiftlint/swiftlint"
"$ROOT/.tools/swiftlint/swiftlint" version
