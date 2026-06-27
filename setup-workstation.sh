#!/usr/bin/env bash
# setup-workstation.sh - Pós-instalação do Arch Linux Workstation
# Uso: bash setup-workstation.sh
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
header(){ echo -e "\n${BOLD}━━━ $1 ━━━${NC}\n"; }

# ─── Configuração ──────────────────────────────────────────────
USERNAME="${USER:-shayani}"
HOSTNAME="${HOSTNAME:-arch-workstation}"
FILESYSTEM="btrfs"   # btrfs ou ext4

SYSTEM_PACKAGES=(
  # Audio
  pipewire pipewire-pulse pipewire-alsa wireplumber
  sof-firmware alsa-utils

  # Hyprland
  hyprland hyprlauncher waybar rofi-wayland alacritty
  dunst libnotify

  # File manager
  thunar thunar-archive-plugin file-roller

  # Fonts
  ttf-jetbrains-mono-nerd noto-fonts-emoji

  # Portal / polkit
  polkit-kde-agent xdg-desktop-portal-hyprland

  # Qt/Wayland
  qt5-wayland qt6-wayland

  # Utils
  brightnessctl pavucontrol bluetui power-profiles-daemon
  grim slurp swappy wl-clipboard cliphist
  swaylock swayidle

  # Bluetooth
  bluez bluez-utils

  # Containers
  docker docker-compose

  # Snapshots
  snapper snap-pac

  # Dev
  git curl wget rsync base-devel man-db man-pages
)

AUR_PACKAGES=(
  visual-studio-code-bin
  spotify
  google-chrome
  slack-desktop
  obsidian
)

# ─── Verificação ───────────────────────────────────────────────
header "Verificações"
[[ $EUID -eq 0 ]] || err "Execute como root (sudo bash setup-workstation.sh)"

# ─── Pacotes do sistema ────────────────────────────────────────
header "Instalando pacotes oficiais"
pacman -S --noconfirm --needed "${SYSTEM_PACKAGES[@]}"

# ─── Serviços ──────────────────────────────────────────────────
header "Ativando serviços"
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable docker
systemctl enable power-profiles-daemon
systemctl enable fstrim.timer

# ─── AUR helper (paru) ─────────────────────────────────────────
header "Instalando paru-bin (AUR helper)"
if ! command -v paru &>/dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/paru-bin.git
  chown -R "$USERNAME": paru-bin
  cd paru-bin
  sudo -u "$USERNAME" makepkg -si --noconfirm
  cd /
  rm -rf /tmp/paru-bin
  info "paru instalado"
else
  info "paru já instalado"
fi

# ─── Pacotes AUR ───────────────────────────────────────────────
header "Instalando pacotes AUR"
for pkg in "${AUR_PACKAGES[@]}"; do
  if ! pacman -Q "$pkg" &>/dev/null; then
    sudo -u "$USERNAME" paru -S --noconfirm "$pkg" || warn "Falha ao instalar $pkg"
  else
    info "$pkg já instalado"
  fi
done

# ─── Chezmoi + dotfiles ────────────────────────────────────────
header "Configurando dotfiles (chezmoi)"
if ! command -v chezmoi &>/dev/null; then
  sudo -u "$USERNAME" sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/$USERNAME/.local/bin
  echo 'export PATH=$HOME/.local/bin:$PATH' >> /home/$USERNAME/.bash_profile
fi
sudo -u "$USERNAME" /home/$USERNAME/.local/bin/chezmoi init --apply https://github.com/shayani/dotfiles.git 2>/dev/null || \
  warn "chezmoi init falhou — execute manualmente após o script"

# ─── Grupo docker ──────────────────────────────────────────────
header "Grupos"
usermod -aG docker "$USERNAME" 2>/dev/null || true

# ─── Swapfile (se btrfs) ───────────────────────────────────────
if [[ "$FILESYSTEM" == "btrfs" ]] && [[ ! -f /swapfile ]]; then
  header "Swapfile"
  truncate -s 0 /swapfile
  chattr +C /swapfile
  fallocate -l 2G /swapfile
  chmod 0600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  grep -q "/swapfile" /etc/fstab || echo "/swapfile none swap defaults 0 0" >> /etc/fstab
fi

# ─── Final ─────────────────────────────────────────────────────
header "Concluído!"
echo "Recomendado reiniciar o sistema agora."
echo "Após reboot, inicie o Hyprland com: Hyprland"
