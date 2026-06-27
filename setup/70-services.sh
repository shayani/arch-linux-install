#!/usr/bin/env bash
# 70-services.sh - Ativar serviços
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Serviços"
servicos NetworkManager
servicos power-profiles-daemon
servicos fstrim.timer
