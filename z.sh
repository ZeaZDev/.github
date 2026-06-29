#!/usr/bin/env bash
# =============================================================================
# GPT-OSS 120B Installation Script
# =============================================================================
# This script automates the deployment of GPT-OSS 120B using vLLM on a system
# equipped with NVIDIA GPU support.
#
# Prerequisites:
#   - Ubuntu/Debian-based system
#   - NVIDIA GPU with drivers installed
#   - Root privileges
# =============================================================================

set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

# Configuration
APP_DIR="/opt/gptoss"
MODEL="openai/gpt-oss-120b"
SERVICE_NAME="gptoss"

log() {
    echo "[$(date '+%F %T')] $*"
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root." >&2
        exit 1
    fi
}

install_packages() {
    log "Updating package index and installing dependencies..."
    apt-get update -qq
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
    if command -v docker >/dev/null 2>&1; then
        log "Docker is already installed."
        return 0
    fi

    log "Installing Docker..."
    curl -fsSL https://get.docker.com | bash
    systemctl enable --now docker
}

install_nvidia_runtime() {
    if ! command -v nvidia-smi >/dev/null 2>&1; then
        log "Error: NVIDIA GPU not detected. nvidia-smi command not found." >&2
        exit 1
    fi

    log "Installing NVIDIA Container Toolkit..."
    apt-get install -y nvidia-container-toolkit
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
}

configure_firewall() {
    log "Configuring UFW firewall..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 8000/tcp
    ufw --force enable
}

create_stack() {
    log "Creating application directory and docker-compose.yml..."
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
      - HUGGING_FACE_HUB_TOKEN=${HF_TOKEN}
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
    log "Creating environment file..."
    cat > "${APP_DIR}/.env" <<EOF
HF_TOKEN=
EOF
    chmod 600 "${APP_DIR}/.env"
    log "Please edit ${APP_DIR}/.env and add your Hugging Face token before starting the service."
}

create_service() {
    log "Creating systemd service..."

    cat > "/etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=GPT-OSS 120B Service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "${SERVICE_NAME}"
}

start_stack() {
    log "Starting GPT-OSS stack..."
    cd "${APP_DIR}"
    docker compose pull
    docker compose up -d
}

healthcheck() {
    log "Performing health check..."
    sleep 20
    if curl -s http://127.0.0.1:8000/v1/models > /dev/null; then
        log "Service appears to be healthy."
    else
        log "Warning: Health check did not receive a successful response."
    fi
}

main() {
    require_root

    log "Starting GPT-OSS 120B installation..."

    install_packages
    install_docker
    install_nvidia_runtime
    configure_firewall
    create_stack
    create_env
    create_service
    start_stack
    healthcheck

    log "================================================================"
    log "Installation completed successfully."
    log "API Endpoint: http://127.0.0.1:8000/v1"
    log ""
    log "Next steps:"
    log "1. Add your Hugging Face token to ${APP_DIR}/.env"
    log "2. Restart the service: systemctl restart ${SERVICE_NAME}"
    log "3. Monitor logs: journalctl -u ${SERVICE_NAME} -f"
    log "================================================================"
}

main "$@"
