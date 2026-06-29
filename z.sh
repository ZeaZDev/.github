#!/usr/bin/env bash
# =============================================================================
# GPT-OSS 120B Installation Script (NVIDIA GPU Optimized)
# =============================================================================
# This script deploys GPT-OSS 120B using vLLM with full NVIDIA GPU support.
#
# Requirements:
#   - Ubuntu/Debian-based Linux
#   - NVIDIA GPU with latest drivers installed
#   - Root privileges
# =============================================================================

set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

# Configuration
APP_DIR="/opt/gptoss"
SERVICE_NAME="gptoss"
MODEL="openai/gpt-oss-120b"

log() {
    echo "[$(date '+%F %T')] $*"
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be executed as root." >&2
        exit 1
    fi
}

detect_gpu() {
    log "Detecting NVIDIA GPU..."
    if ! command -v nvidia-smi >/dev/null 2>&1; then
        log "Error: NVIDIA GPU not detected (nvidia-smi not found)." >&2
        log "Please install NVIDIA drivers first." >&2
        exit 1
    fi

    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
}

install_packages() {
    log "Installing system dependencies..."
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

    log "Installing Docker Engine..."
    curl -fsSL https://get.docker.com | bash
    systemctl enable --now docker
}

install_nvidia_runtime() {
    log "Installing NVIDIA Container Toolkit..."
    apt-get install -y nvidia-container-toolkit

    log "Configuring Docker for NVIDIA runtime..."
    nvidia-ctk runtime configure --runtime=docker

    systemctl restart docker
    log "NVIDIA GPU support enabled for Docker."
}

configure_firewall() {
    log "Configuring firewall (UFW)..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 8000/tcp
    ufw --force enable
}

create_stack() {
    log "Creating application directory and docker-compose configuration..."

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
      --enforce-eager
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
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
}

create_service() {
    log "Creating systemd service..."

    cat > "/etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=GPT-OSS 120B (vLLM GPU)
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
    log "Pulling and starting GPU-accelerated stack..."
    cd "${APP_DIR}"
    docker compose pull
    docker compose up -d
}

healthcheck() {
    log "Running health check..."
    sleep 25
    if curl -s --max-time 10 http://127.0.0.1:8000/v1/models > /dev/null; then
        log "Service is responding."
    else
        log "Warning: Health check did not receive immediate response (model may still be loading)."
    fi
}

main() {
    require_root

    log "=== GPT-OSS 120B Installation (NVIDIA GPU) ==="

    detect_gpu
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
    log "API Endpoint: http://YOUR_SERVER_IP:8000/v1"
    log ""
    log "Important next steps:"
    log "1. Edit ${APP_DIR}/.env and insert your Hugging Face token"
    log "2. Restart service: systemctl restart ${SERVICE_NAME}"
    log "3. Monitor logs: journalctl -u ${SERVICE_NAME} -f"
    log "4. GPU usage: nvidia-smi"
    log "================================================================"
}

main "$@"
