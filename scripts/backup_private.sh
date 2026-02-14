#!/usr/bin/env bash
set -euo pipefail

# Backup private data directories to GCS
# Usage: backup_private.sh [BUCKET_NAME]
# Intended to run as a daily cron job on the VM:
#   0 3 * * * /opt/brain/scripts/backup_private.sh llm-server-447708-brain-private

BUCKET="${1:-llm-server-447708-brain-private}"
DATA_DIR="/opt/brain/data"
PRIVATE_DIRS=("idea" "project" "contracts")

for dir in "${PRIVATE_DIRS[@]}"; do
  src="${DATA_DIR}/${dir}/"
  dst="gs://${BUCKET}/${dir}/"
  if [ -d "$src" ]; then
    echo "[$(date -Iseconds)] Syncing ${dir} → ${dst}"
    gsutil -m rsync -r -d "$src" "$dst"
  else
    echo "[$(date -Iseconds)] Skipping ${dir} (not found: ${src})"
  fi
done

echo "[$(date -Iseconds)] Backup complete."
