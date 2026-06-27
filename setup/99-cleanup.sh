#!/usr/bin/env bash
# 99-cleanup.sh - Ajustes finais
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Swapfile (btrfs)"
if [[ -f /swapfile ]]; then
  ok "swapfile já existe"
else
  truncate -s 0 /swapfile
  chattr +C /swapfile
  fallocate -l 2G /swapfile
  chmod 0600 /swapfile && mkswap /swapfile && swapon /swapfile
  grep -q /swapfile /etc/fstab || echo "/swapfile none swap defaults 0 0" >> /etc/fstab
  ok "swapfile criado"
fi
