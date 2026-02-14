#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/opt/brain/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="apps-postgres-1"

mkdir -p "$BACKUP_DIR"

docker exec "$CONTAINER_NAME" pg_dump -U mattermost mattermost \
  | gzip > "$BACKUP_DIR/mattermost_${TIMESTAMP}.sql.gz"

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

echo "✅ Backup saved: $BACKUP_DIR/mattermost_${TIMESTAMP}.sql.gz"
