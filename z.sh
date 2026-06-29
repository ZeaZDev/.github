#!/usr/bin/env bash
# =============================================================================
# Automated Ollama Installer for AMD Ryzen 5 3400G
# Optimized for CPU + Integrated Graphics
# =============================================================================

set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive
APP_DIR="/opt/ollama"
SERVICE_NAME="ollama"

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
    log "Installing system dependencies..."
    apt-get update -qq
    apt-get install -y \
        curl \
        wget \
        git \
        ca-certificates \
        ufw \
        fail2ban
}

install_ollama() {
    if command -v ollama >/dev/null 2>&1; then
        log "Ollama is already installed."
        return 0
    fi

    log "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
}

configure_firewall() {
    log "Configuring firewall..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 11434/tcp
    ufw --force enable
}

create_service() {
    log "Creating systemd service for Ollama..."
    
    cat > "/etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=Ollama Service (AMD Ryzen 3400G)
After=network.target

[Service]
Type=simple
User=root
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_ORIGINS=*"
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now "${SERVICE_NAME}"
}

pull_models() {
    log "Pulling recommended models for your hardware..."
    log "This may take some time depending on your internet speed."

    # Recommended models for Ryzen 5 3400G (practical sizes)
    ollama pull llama3.2:3b     # Fastest
    ollama pull phi4:3.8b       # Good balance
    ollama pull gemma2:9b       # Higher quality (if RAM allows)
    
    log "Models pulled successfully."
}

healthcheck() {
    log "Performing health check..."
    sleep 8
    if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
        log "Ollama service is running successfully."
    else
        log "Warning: Health check incomplete."
    fi
}

main() {
    require_root

    log "================================================================"
    log "Starting Automated Ollama Installation for AMD Ryzen 5 3400G"
    log "================================================================"

    install_packages
    install_ollama
    configure_firewall
    create_service
    pull_models
    healthcheck

    log "================================================================"
    log "Installation Completed Successfully!"
    log ""
    log "Access your local AI at: http://YOUR_SERVER_IP:11434"
    log ""
    log "Useful commands:"
    log "   ollama list                    → Show installed models"
    log "   ollama run llama3.2:3b         → Chat with model"
    log "   ollama ps                      → Show running models"
    log "   systemctl status ollama        → Check service status"
    log "================================================================"
}

main "$@"
