#!/usr/bin/env bash
# 52-1password.sh - Instalação do 1Password
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "1Password"

if [[ -f /opt/1Password/1password ]]; then
  ok "1Password já instalado"
  exit 0
fi

cd /tmp

info "Baixando 1Password (200MB)..."
curl -L "https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz" -o 1password.tar.gz

info "Extraindo..."
tar -xf 1password.tar.gz
DIR_NAME=$(ls -d 1password-*/ | head -1)

info "Instalando..."
sudo mkdir -p /opt/1Password
sudo cp -r "$DIR_NAME"* /opt/1Password/
sudo ln -sf /opt/1Password/1password /usr/bin/1password

sudo tee /usr/share/applications/1password.desktop << 'DESKTOP'
[Desktop Entry]
Name=1Password
Comment=Password Manager
Exec=/opt/1Password/1password %U
Icon=1password
Type=Application
Categories=Utility;
MimeType=x-scheme-handler/onepassword;
DESKTOP

rm -rf 1password.tar.gz "$DIR_NAME"
ok "1Password $(1password --version) instalado em /opt/1Password/"
