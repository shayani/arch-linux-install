#!/usr/bin/env bash
# 50-aur.sh - AUR helper + pacotes AUR
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "AUR helper (paru)"
if ! command -v paru &>/dev/null; then
  rm -rf /tmp/paru-bin
  cd /tmp
  git clone https://aur.archlinux.org/paru-bin.git
  chown -R "$SUDO_USER": paru-bin 2>/dev/null || true
  cd paru-bin && sudo -u "$SUDO_USER" makepkg -si --noconfirm
  cd / && rm -rf /tmp/paru-bin
  ok "paru instalado"
else
  ok "paru já instalado"
fi

header "Pacotes AUR"
# Lista vazia por enquanto — adicione aqui seus AUR packages
AUR_PACKAGES=()
for pkg in "${AUR_PACKAGES[@]}"; do
  pacman -Q "$pkg" &>/dev/null && ok "$pkg" || {
    sudo -u "$USER" paru -S --noconfirm "$pkg" || warn "Falha: $pkg"
  }
done
