#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
if [ -x "$ROOT/.tools/swiftlint/swiftlint" ]; then
  LINTER="$ROOT/.tools/swiftlint/swiftlint"
elif command -v swiftlint >/dev/null 2>&1; then
  LINTER="$(command -v swiftlint)"
else
  echo "error: SwiftLint отсутствует. Запустите: sh Scripts/install-swiftlint.sh"
  exit 1
fi
# SourceKit из Command Line Tools, если полный Xcode не выбран.
DEV_DIR="$(xcode-select -p 2>/dev/null || true)"
if [ -z "${XCODE_DEFAULT_TOOLCHAIN_OVERRIDE:-}" ] && [ -f "$DEV_DIR/usr/lib/sourcekitdInProc.framework/Versions/A/sourcekitdInProc" ]; then
  export XCODE_DEFAULT_TOOLCHAIN_OVERRIDE="$DEV_DIR"
fi
exec "$LINTER" lint --config "$ROOT/.swiftlint.yml" --no-cache "$@"
