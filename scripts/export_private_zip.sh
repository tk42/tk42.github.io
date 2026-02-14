#!/usr/bin/env bash
set -euo pipefail

# Export private data as a timestamped zip file
# Usage: export_private_zip.sh [DATA_DIR] [EXPORT_DIR]
#
# Intended to run on the VM:
#   export_private_zip.sh /opt/brain/data /opt/brain/data/export

DATA_DIR="${1:-/opt/brain/data}"
EXPORT_DIR="${2:-/opt/brain/data/export}"
PRIVATE_DIRS=("idea" "project" "contracts")
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
ZIP_NAME="private-data-${TIMESTAMP}.zip"

mkdir -p "$EXPORT_DIR"

# Remove old exports (keep last 3)
cd "$EXPORT_DIR"
ls -t private-data-*.zip 2>/dev/null | tail -n +4 | xargs -r rm -f
cd - > /dev/null

# Build zip from private directories
TEMP_DIR="$(mktemp -d)"
for dir in "${PRIVATE_DIRS[@]}"; do
  src="${DATA_DIR}/${dir}"
  if [ -d "$src" ]; then
    cp -r "$src" "${TEMP_DIR}/${dir}"
  fi
done

cd "$TEMP_DIR"
zip -r "${EXPORT_DIR}/${ZIP_NAME}" . -x '*.DS_Store'
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo "[$(date -Iseconds)] Exported: ${EXPORT_DIR}/${ZIP_NAME}"
echo "Download URL: https://chat.tk42.jp/export/${ZIP_NAME}"
