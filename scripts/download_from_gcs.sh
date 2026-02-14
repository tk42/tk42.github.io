#!/usr/bin/env bash
set -euo pipefail

# Download private data from GCS to local machine
# Usage: download_from_gcs.sh [DATA_DIR] [BUCKET_NAME]
#
# Example:
#   ./scripts/download_from_gcs.sh ./data llm-server-447708-brain-private

DATA_DIR="${1:-./data}"
BUCKET="${2:-llm-server-447708-brain-private}"
PRIVATE_DIRS=("idea" "project" "contracts")

echo "Downloading private data from gs://${BUCKET}/ to ${DATA_DIR}/"
echo ""

for dir in "${PRIVATE_DIRS[@]}"; do
  src="gs://${BUCKET}/${dir}/"
  dst="${DATA_DIR}/${dir}/"
  mkdir -p "$dst"
  echo "[$(date -Iseconds)] Downloading ${dir} ← ${src}"
  gsutil -m rsync -r "$src" "$dst"
  echo "[$(date -Iseconds)] Done: ${dir}"
done

echo ""
echo "[$(date -Iseconds)] Download complete."
