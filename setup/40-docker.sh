#!/usr/bin/env bash
# 40-docker.sh - Docker
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Docker"
pacotes docker docker-compose
servicos docker
usermod -aG docker "$USER" 2>/dev/null || true
