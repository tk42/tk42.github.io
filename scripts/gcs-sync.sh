#!/usr/bin/env bash
set -euo pipefail

# Unified GCS sync script for private data (idea, project, contracts)
#
# Usage:
#   gcs-sync.sh push [DATA_DIR] [BUCKET]           # local/VM → GCS
#   gcs-sync.sh push --delete [DATA_DIR] [BUCKET]   # VM → GCS (mirror, deletes remote orphans)
#   gcs-sync.sh pull [DATA_DIR] [BUCKET]            # GCS → local/VM
#   gcs-sync.sh export [DATA_DIR] [EXPORT_DIR]      # zip private data
#
# Examples:
#   ./scripts/gcs-sync.sh push ./data                # Mac: upload to GCS
#   ./scripts/gcs-sync.sh pull /opt/brain/data       # VM: pull from GCS
#   ./scripts/gcs-sync.sh export /opt/brain/data /opt/brain/data/export

BUCKET_DEFAULT="llm-server-447708-brain-private"
PRIVATE_DIRS=("idea" "project" "contracts")

log() { echo "[$(date -Iseconds)] $*"; }

cmd_push() {
  local delete_flag=""
  if [[ "${1:-}" == "--delete" ]]; then
    delete_flag="-d"
    shift
  fi

  local data_dir="${1:-./data}"
  local bucket="${2:-$BUCKET_DEFAULT}"

  for dir in "${PRIVATE_DIRS[@]}"; do
    local src="${data_dir}/${dir}/"
    local dst="gs://${bucket}/${dir}/"
    if [ -d "$src" ]; then
      log "Pushing ${dir} → ${dst}"
      gsutil -m rsync -r $delete_flag "$src" "$dst"
    else
      log "Skipping ${dir} (not found: ${src})"
    fi
  done
  log "Push complete."
}

cmd_pull() {
  local data_dir="${1:-./data}"
  local bucket="${2:-$BUCKET_DEFAULT}"

  for dir in "${PRIVATE_DIRS[@]}"; do
    local src="gs://${bucket}/${dir}/"
    local dst="${data_dir}/${dir}/"
    mkdir -p "$dst"
    log "Pulling ${src} → ${dst}"
    gsutil -m rsync -r "$src" "$dst"
  done
  log "Pull complete."
}

cmd_export() {
  local data_dir="${1:-/opt/brain/data}"
  local export_dir="${2:-/opt/brain/data/export}"
  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"
  local zip_name="private-data-${timestamp}.zip"

  mkdir -p "$export_dir"

  # Remove old exports (keep last 3)
  cd "$export_dir"
  ls -t private-data-*.zip 2>/dev/null | tail -n +4 | xargs -r rm -f
  cd - > /dev/null

  # Build zip from private directories
  local temp_dir
  temp_dir="$(mktemp -d)"
  for dir in "${PRIVATE_DIRS[@]}"; do
    local src="${data_dir}/${dir}"
    if [ -d "$src" ]; then
      cp -r "$src" "${temp_dir}/${dir}"
    fi
  done

  cd "$temp_dir"
  zip -r "${export_dir}/${zip_name}" . -x '*.DS_Store'
  cd - > /dev/null
  rm -rf "$temp_dir"

  log "Exported: ${export_dir}/${zip_name}"
  echo "Download URL: https://chat.tk42.jp/export/${zip_name}"
}

usage() {
  echo "Usage: $0 {push|pull|export} [options]"
  echo ""
  echo "Commands:"
  echo "  push [--delete] [DATA_DIR] [BUCKET]   Upload private data to GCS"
  echo "  pull [DATA_DIR] [BUCKET]               Download private data from GCS"
  echo "  export [DATA_DIR] [EXPORT_DIR]         Create zip of private data"
  exit 1
}

case "${1:-}" in
  push)   shift; cmd_push "$@" ;;
  pull)   shift; cmd_pull "$@" ;;
  export) shift; cmd_export "$@" ;;
  *)      usage ;;
esac
