#!/usr/bin/env bash
# 55-screenshare.sh - Configuração de compartilhamento de tela
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Compartilhamento de tela (Wayland)"

# Garantir portal do Hyprland
pacotes xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# Criar atalho Chrome com flags Wayland
APPS_DIR="/home/$USER/.local/share/applications"
mkdir -p "$APPS_DIR"

if [[ -f /usr/bin/google-chrome-stable ]]; then
  ENTRY="$APPS_DIR/google-chrome-wayland.desktop"
  if [[ ! -f "$ENTRY" ]]; then
    cat > "$ENTRY" << 'CHROME'
[Desktop Entry]
Version=1.0
Name=Google Chrome (Wayland)
Comment=Access the internet
Exec=/usr/bin/google-chrome-stable --enable-features=WebRTCPipeWireCapturer --ozone-platform-hint=auto %U
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
CHROME
    ok "Atalho Chrome Wayland criado"
  else
    ok "Atalho Chrome Wayland já existe"
  fi
else
  warn "Google Chrome não instalado — crie o atalho manualmente se instalar depois"
fi
