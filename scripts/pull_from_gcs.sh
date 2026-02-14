#!/usr/bin/env bash
set -euo pipefail

# Pull private data from GCS to local data directory
# Usage: pull_from_gcs.sh [DATA_DIR] [BUCKET_NAME]
#
# On VM:   pull_from_gcs.sh /opt/brain/data
# On Mac:  pull_from_gcs.sh ./data
#
# Intended to run as a cron job on the VM:
#   0 * * * * /opt/brain/scripts/pull_from_gcs.sh /opt/brain/data llm-server-447708-brain-private

DATA_DIR="${1:-/opt/brain/data}"
BUCKET="${2:-llm-server-447708-brain-private}"
PRIVATE_DIRS=("idea" "project" "contracts")

for dir in "${PRIVATE_DIRS[@]}"; do
  src="gs://${BUCKET}/${dir}/"
  dst="${DATA_DIR}/${dir}/"
  mkdir -p "$dst"
  echo "[$(date -Iseconds)] Pulling ${src} → ${dst}"
  gsutil -m rsync -r "$src" "$dst"
done

echo "[$(date -Iseconds)] Pull complete."
