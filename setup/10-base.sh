#!/usr/bin/env bash
# 10-base.sh - Pacotes base do sistema
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Base: áudio, firmware, utilitários"
pacotes pipewire pipewire-pulse pipewire-alsa wireplumber
pacotes sof-firmware alsa-utils
pacotes git curl wget rsync base-devel man-db man-pages
pacotes brightnessctl pavucontrol grim slurp swappy
pacotes wl-clipboard cliphist swaylock swayidle
pacotes ttf-jetbrains-mono-nerd noto-fonts-emoji
pacotes chezmoi
