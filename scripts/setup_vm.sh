#!/usr/bin/env bash
set -euo pipefail

# Install Docker CE
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

# Install Docker Compose plugin
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

# Clone repository
cd /opt
sudo git clone https://github.com/tk42/tk42.github.io.git brain

# Create private data directories (not tracked by git)
sudo mkdir -p /opt/brain/data/{idea,project,contracts}

cd brain/apps

# Copy .env (must be manually configured)
if [ ! -f .env ]; then
  sudo cp .env.example .env
  echo "⚠️  Edit /opt/brain/apps/.env before starting services"
  exit 1
fi

# Start services
sudo docker compose up -d

echo "✅ Services started. Access Mattermost at https://chat.tk42.jp"
