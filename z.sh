#!/usr/bin/env bash

set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

APP_DIR="/opt/gptoss"
MODEL="openai/gpt-oss-120b"

log() {
  echo "[$(date '+%F %T')] $*"
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Run as root"
    exit 1
  fi
}

install_packages() {

  apt-get update

  apt-get install -y \
    curl \
    wget \
    git \
    jq \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban
}

install_docker() {

  if command -v docker >/dev/null; then
      return
  fi

  curl -fsSL https://get.docker.com | bash

  systemctl enable docker
  systemctl start docker
}

install_nvidia_runtime() {

  if ! command -v nvidia-smi >/dev/null; then
      echo "NVIDIA GPU not found"
      exit 1
  fi

  apt-get install -y nvidia-container-toolkit

  nvidia-ctk runtime configure \
      --runtime=docker

  systemctl restart docker
}

configure_firewall() {

  ufw default deny incoming
  ufw default allow outgoing

  ufw allow 22/tcp
  ufw allow 8000/tcp

  ufw --force enable
}

create_stack() {

  mkdir -p "${APP_DIR}"

  cat > "${APP_DIR}/docker-compose.yml" <<'EOF'
services:

  gptoss:

    image: vllm/vllm-openai:latest

    container_name: gptoss120b

    restart: unless-stopped

    runtime: nvidia

    ports:
      - "8000:8000"

    shm_size: "32gb"

    environment:
      HUGGING_FACE_HUB_TOKEN: ${HF_TOKEN}

    command: >
      --model openai/gpt-oss-120b
      --gpu-memory-utilization 0.95
      --max-model-len 131072
      --tensor-parallel-size 1

    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]

    volumes:
      - model_cache:/root/.cache/huggingface

volumes:
  model_cache:
EOF
}

create_env() {

cat > "${APP_DIR}/.env" <<EOF
HF_TOKEN=
EOF

chmod 600 "${APP_DIR}/.env"
}

create_service() {

cat > /etc/systemd/system/gptoss.service <<EOF
[Unit]
Description=GPT OSS 120B
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes

WorkingDirectory=${APP_DIR}

ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable gptoss
}

start_stack() {

  cd "${APP_DIR}"

  docker compose pull

  docker compose up -d
}

healthcheck() {

  sleep 20

  curl -s \
    http://127.0.0.1:8000/v1/models \
    || true
}

main() {

  require_root

  log "Installing packages..."
  install_packages

  log "Installing Docker..."
  install_docker

  log "Configuring NVIDIA runtime..."
  install_nvidia_runtime

  log "Configuring firewall..."
  configure_firewall

  log "Creating stack..."
  create_stack

  log "Creating env..."
  create_env

  log "Creating service..."
  create_service

  log "Starting stack..."
  start_stack

  log "Healthcheck..."
  healthcheck

  log "====================================="
  log "GPT-OSS-120B Installed"
  log "API Endpoint:"
  log "http://SERVER-IP:8000/v1"
  log "====================================="
}

main "$@"
