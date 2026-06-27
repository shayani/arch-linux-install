#!/usr/bin/env bash
set -euo pipefail

# === VM test: one-shot install ===
export DISK="/dev/vda"
export HOSTNAME="arch-vm"
export USERNAME="shayani"
export PASSWORD="test123"
export TIMEZONE="America/Sao_Paulo"
export LOCALE="pt_BR.UTF-8"
export KEYMAP="br-abnt2"
export FILESYSTEM="btrfs"
export SWAP_SIZE="2G"
export GPU="auto"
export DOTFILES_REPO="https://github.com/shayani/dotfiles.git"
export CHEZMOI_INSTALL="binary"
export AUR_HELPER="yay"

# Download installer + lib files
TMP=$(mktemp -d)
echo "Downloading installer..."
curl -fsSL "http://192.168.122.1:8000/install.sh" -o "$TMP/install.sh"
mkdir -p "$TMP/lib"
for mod in helpers preflight disk system user bootloader finalize; do
  curl -fsSL "http://192.168.122.1:8000/lib/${mod}.sh" -o "$TMP/lib/${mod}.sh"
done

cd "$TMP" && bash install.sh
