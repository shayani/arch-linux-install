#!/usr/bin/env bash
# 20-hyprland.sh - Hyprland + interface
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Hyprland + Wayland"
pacotes hyprland hyprlauncher waybar rofi-wayland
pacotes hypridle hyprpaper
pacotes dunst libnotify
pacotes hyprpolkitagent xdg-desktop-portal-hyprland
pacotes qt5-wayland qt6-wayland
pacotes thunar thunar-archive-plugin file-roller
