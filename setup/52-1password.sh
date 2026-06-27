#!/usr/bin/env bash
# 52-1password.sh - Instalação do 1Password
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "1Password"

if pacman -Q 1password-beta 1password-cli &>/dev/null; then
  ok "1Password já instalado"
  exit 0
fi

info "Instalando 1Password-beta + 1Password-CLI via yay..."
sudo -u "$SUDO_USER" yay -S --noconfirm --needed 1password-beta 1password-cli

ok "1Password $(1password --version) instalado"
