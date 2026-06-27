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

TMPDIR=$(mktemp -d /tmp/arch-install.XXXXXXXXXX)
curl -fsSL "http://192.168.122.1:8000/install.sh" -o "$TMPDIR/install.sh"
mkdir -p "$TMPDIR/lib"
for mod in helpers preflight disk system user bootloader finalize; do
  curl -fsSL "http://192.168.122.1:8000/lib/${mod}.sh" -o "$TMPDIR/lib/${mod}.sh"
done

bash "$TMPDIR/install.sh"
