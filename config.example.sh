#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  Arch Linux Installer — Configuration
#  Copy this to config.sh and edit, or set env vars directly.
#  Usage: CONFIG_FILE=./config.sh bash install.sh
# ──────────────────────────────────────────────────────────────

# Disk to install on (e.g. /dev/nvme0n1, /dev/sda)
# Leave empty for interactive selection
DISK="/dev/nvme0n1"

# System
HOSTNAME="arch"
USERNAME="shayani"
# Leave empty to be prompted during install
PASSWORD=""
TIMEZONE="America/Sao_Paulo"
LOCALE="pt_BR.UTF-8"
KEYMAP="br-abnt2"
KERNEL="linux"                   # linux, linux-zen, linux-lts

# Storage
FILESYSTEM="btrfs"               # btrfs or ext4
SWAP_SIZE="4G"                   # swapfile size (btrfs only)

# GPU: auto, amd, intel, nvidia
GPU="auto"

# Dotfiles (chezmoi)
DOTFILES_REPO="https://github.com/shayani/dotfiles.git"
CHEZMOI_INSTALL="aur"            # aur or binary

# AUR helper
AUR_HELPER="yay"                 # yay or paru
