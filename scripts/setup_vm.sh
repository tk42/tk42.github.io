#!/usr/bin/env bash
set -euo pipefail

BRAIN_DIR="/opt/brain"
BUCKET="llm-server-447708-brain-private"

# Install Docker CE
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

# Install Docker Compose plugin
sudo apt-get update
sudo apt-get install -y docker-compose-plugin zip

# Install Google Cloud CLI (for gsutil)
if ! command -v gsutil &> /dev/null; then
  echo "Installing Google Cloud CLI..."
  curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=/opt
  ln -sf /opt/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil
  ln -sf /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
fi

# Clone repository
if [ ! -d "$BRAIN_DIR" ]; then
  cd /opt
  sudo git clone https://github.com/tk42/tk42.github.io.git brain
fi

# Create private data directories (not tracked by git)
sudo mkdir -p "${BRAIN_DIR}/data/{idea,project,contracts}"
sudo mkdir -p "${BRAIN_DIR}/data/export"

# Pull private data from GCS
# NOTE: VM must have a service account with Storage Object Viewer role on the bucket,
#       or run `gcloud auth login` / `gcloud auth activate-service-account` first.
echo "Pulling private data from GCS..."
bash "${BRAIN_DIR}/scripts/pull_from_gcs.sh" "${BRAIN_DIR}/data" "$BUCKET"

# Make scripts executable
chmod +x "${BRAIN_DIR}/scripts/"*.sh

# Register cron jobs (pull hourly, backup daily at 3am, export daily at 4am)
CRON_PULL="0 * * * * ${BRAIN_DIR}/scripts/pull_from_gcs.sh ${BRAIN_DIR}/data ${BUCKET} >> /var/log/brain-pull.log 2>&1"
CRON_BACKUP="0 3 * * * ${BRAIN_DIR}/scripts/backup_private.sh ${BUCKET} >> /var/log/brain-backup.log 2>&1"
CRON_EXPORT="0 4 * * * ${BRAIN_DIR}/scripts/export_private_zip.sh ${BRAIN_DIR}/data ${BRAIN_DIR}/data/export >> /var/log/brain-export.log 2>&1"

# Install cron jobs (idempotent)
( crontab -l 2>/dev/null | grep -v "brain-pull\|brain-backup\|brain-export\|pull_from_gcs\|backup_private\|export_private_zip"; \
  echo "$CRON_PULL"; echo "$CRON_BACKUP"; echo "$CRON_EXPORT" ) | crontab -

echo "✅ Cron jobs registered."

cd "${BRAIN_DIR}/apps"

# Copy .env (must be manually configured)
if [ ! -f .env ]; then
  sudo cp .env.example .env
  echo "⚠️  Edit /opt/brain/apps/.env before starting services"
  echo "   Required: EXPORT_BASIC_AUTH_HASH (generate with: caddy hash-password)"
  exit 1
fi

# Start services
sudo docker compose up -d

echo "✅ Services started. Access Mattermost at https://chat.tk42.jp"
