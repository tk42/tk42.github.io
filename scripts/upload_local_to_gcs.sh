#!/usr/bin/env bash
set -euo pipefail

# One-shot script to upload local private data to GCS
# Usage: upload_local_to_gcs.sh [DATA_DIR] [BUCKET_NAME]
#
# Example:
#   ./scripts/upload_local_to_gcs.sh ./data llm-server-447708-brain-private

DATA_DIR="${1:-.}"
BUCKET="${2:-llm-server-447708-brain-private}"
PRIVATE_DIRS=("idea" "project" "contracts")

echo "Uploading private data from ${DATA_DIR} to gs://${BUCKET}/"
echo ""

for dir in "${PRIVATE_DIRS[@]}"; do
  src="${DATA_DIR}/${dir}/"
  dst="gs://${BUCKET}/${dir}/"
  if [ -d "$src" ]; then
    echo "[$(date -Iseconds)] Uploading ${dir} → ${dst}"
    gsutil -m rsync -r "$src" "$dst"
    echo "[$(date -Iseconds)] Done: ${dir}"
  else
    echo "[$(date -Iseconds)] Skipping ${dir} (not found: ${src})"
  fi
done

echo ""
echo "[$(date -Iseconds)] Upload complete."
