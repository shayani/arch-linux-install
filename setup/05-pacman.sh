#!/usr/bin/env bash
# 05-pacman.sh - Configurar pacman
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Configurando pacman"

# ILoveCandy (animação legal no progresso)
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sed -i '/^#Misc options/a ILoveCandy' /etc/pacman.conf
  ok "ILoveCandy ativado"
else
  ok "ILoveCandy já ativo"
fi

# Parallel downloads
if grep -q "^#ParallelDownloads" /etc/pacman.conf; then
  sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
  ok "ParallelDownloads ativado"
else
  ok "ParallelDownloads já ativo"
fi
