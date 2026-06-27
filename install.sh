#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
#  Arch Linux + Hyprland automated installer
#  Usage: bash <(curl -fsSL https://raw.githubusercontent.com/shayani/arch-linux-install/main/install.sh)
# ──────────────────────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
header(){ echo -e "\n${BOLD}━━━ $1 ━━━${NC}\n"; }

# ── Load config ───────────────────────────────────────────────
CONFIG_FILE="${CONFIG_FILE:-./config.sh}"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  info "Config loaded from $CONFIG_FILE"
fi

# ── Defaults ──────────────────────────────────────────────────
DISK="${DISK:-}"
HOSTNAME="${HOSTNAME:-arch}"
USERNAME="${USERNAME:-shayani}"
PASSWORD="${PASSWORD:-}"
TIMEZONE="${TIMEZONE:-America/Sao_Paulo}"
LOCALE="${LOCALE:-pt_BR.UTF-8}"
KEYMAP="${KEYMAP:-br-abnt2}"
KERNEL="${KERNEL:-linux}"
FILESYSTEM="${FILESYSTEM:-btrfs}"
SWAP_SIZE="${SWAP_SIZE:-4G}"
GPU="${GPU:-auto}"
AUR_HELPER="${AUR_HELPER:-paru}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/shayani/dotfiles.git}"
CHEZMOI_INSTALL="${CHEZMOI_INSTALL:-aur}"

# ── Pre-flight checks ─────────────────────────────────────────
header "Pre-flight checks"

[[ $EUID -eq 0 ]] || err "This script must be run as root"
[[ -d /sys/firmware/efi ]] || err "This script supports UEFI only"
ping -c1 -W2 archlinux.org &>/dev/null || err "No internet connection"

# Detect disk interactively if not set
if [[ -z "$DISK" ]]; then
  echo ""
  lsblk -dno NAME,SIZE,MODEL | awk '{print "  /dev/"$0}'
  echo ""
  read -rp "Target disk (e.g. /dev/nvme0n1): " DISK
  [[ -b "$DISK" ]] || err "Invalid disk: $DISK"
fi

# Detect GPU
if [[ "$GPU" == "auto" ]]; then
  if lspci | grep -qi "nvidia"; then
    GPU="nvidia"
  elif lspci | grep -qi "amd.*graphics"; then
    GPU="amd"
  elif lspci | grep -qi "intel.*graphics"; then
    GPU="intel"
  else
    GPU="amd"
  fi
  info "Detected GPU: ${GPU}"
fi

# Get password if not set
if [[ -z "$PASSWORD" ]]; then
  while true; do
    read -rsp "Password for root + $USERNAME: " PASSWORD; echo
    read -rsp "Confirm password: " PASSWORD2; echo
    [[ "$PASSWORD" == "$PASSWORD2" ]] && break
    warn "Passwords do not match, try again"
  done
fi

# Derived paths
if echo "$DISK" | grep -q "nvme"; then
  PART_PREFIX="${DISK}p"
elif echo "$DISK" | grep -q "mmcblk"; then
  PART_PREFIX="${DISK}p"
else
  PART_PREFIX="${DISK}"
fi
EFI_PART="${PART_PREFIX}1"
ROOT_PART="${PART_PREFIX}2"
EFI_MOUNT="/mnt/boot"

# ── Partitioning ──────────────────────────────────────────────
header "Partitioning $DISK"

info "Wiping existing partition table"
wipefs -af "$DISK" &>/dev/null || true

info "Creating GPT partition table and partitions"
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1024MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary 1024MiB 100%

sleep 1
partprobe "$DISK" 2>/dev/null || true
sleep 1

info "Formatting EFI partition"
mkfs.fat -F32 "$EFI_PART"

# ── Filesystem ────────────────────────────────────────────────
if [[ "$FILESYSTEM" == "btrfs" ]]; then
  header "Btrfs setup"

  info "Formatting root partition as btrfs"
  mkfs.btrfs "$ROOT_PART" -f

  info "Mounting root partition to create subvolumes"
  mount "$ROOT_PART" /mnt

  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@snapshots
  btrfs subvolume create /mnt/@var_log
  btrfs subvolume create /mnt/@cache

  umount /mnt

  MOUNT_OPTS="compress=zstd:3,noatime"

  info "Mounting subvolumes"
  mount -o "$MOUNT_OPTS",subvol=@ "$ROOT_PART" /mnt
  mount --mkdir -o "$MOUNT_OPTS",subvol=@home "$ROOT_PART" /mnt/home
  mount --mkdir -o "$MOUNT_OPTS",subvol=@snapshots "$ROOT_PART" /mnt/.snapshots
  mount --mkdir -o "$MOUNT_OPTS",subvol=@var_log "$ROOT_PART" /mnt/var/log
  mount --mkdir -o "$MOUNT_OPTS",subvol=@cache "$ROOT_PART" /mnt/var/cache

  # Create swapfile
  info "Creating swapfile ($SWAP_SIZE)"
  truncate -s 0 /mnt/@/swapfile
  chattr +C /mnt/@/swapfile
  fallocate -l "$SWAP_SIZE" /mnt/@/swapfile
  chmod 0600 /mnt/@/swapfile
  mkswap /mnt/@/swapfile

else
  header "ext4 setup"

  info "Formatting root partition as ext4"
  mkfs.ext4 "$ROOT_PART"

  mount "$ROOT_PART" /mnt
fi

info "Mounting EFI partition"
mount --mkdir "$EFI_PART" "$EFI_MOUNT"

# ── Pacstrap ──────────────────────────────────────────────────
header "Installing base system"

PACKAGES=(
  base base-devel
  "$KERNEL" "$KERNEL-headers" linux-firmware
  "$(lscpu | grep -qi "intel" && echo "intel-ucode" || echo "amd-ucode")"
  btrfs-progs dosfstools
  sudo nano vim git curl wget rsync
  networkmanager nm-connection-editor
  pipewire pipewire-pulse pipewire-alsa wireplumber
  hyprland waybar rofi-wayland alacritty
  dunst libnotify
  thunar thunar-archive-plugin file-roller
  ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-font-awesome
  polkit-kde-agent xdg-desktop-portal-hyprland
  qt5-wayland qt6-wayland
  brightnessctl pavucontrol
  grim slurp swappy
  wl-clipboard cliphist
  swaylock swayidle
  bluez bluez-utils
  man-db man-pages
)

if [[ "$FILESYSTEM" == "btrfs" ]]; then
  PACKAGES+=(snapper snap-pac)
fi

if [[ "$GPU" == "nvidia" ]]; then
  PACKAGES+=(nvidia-dkms nvidia-settings nvidia-utils libva-nvidia-driver)
fi

info "Installing packages (this may take a while)"
pacstrap -K /mnt "${PACKAGES[@]}"

# ── fstab ─────────────────────────────────────────────────────
header "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Show fstab for review
info "/mnt/etc/fstab:"
cat /mnt/etc/fstab

# ── Chroot configuration ─────────────────────────────────────
header "System configuration"

arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

# Time
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Locale
sed -i 's/^#$LOCALE/$LOCALE/' /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname

# Hosts
cat > /etc/hosts <<-HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS

# Initramfs hooks for nvidia + btrfs
if [[ "$GPU" == "nvidia" ]]; then
  sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
fi
if [[ "$FILESYSTEM" == "btrfs" ]]; then
  sed -i 's/^HOOKS=(base udev/HOOKS=(base udev btrfs /' /etc/mkinitcpio.conf
fi
mkinitcpio -P

# Root password
echo "root:$PASSWORD" | chpasswd

# User
useradd -m -G wheel,audio,video,storage,optical -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Sudo
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
# Uncomment to allow passwordless sudo:
# echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Enable services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable fstrim.timer

# NVIDIA DRM mode-setting
if [[ "$GPU" == "nvidia" ]]; then
  mkdir -p /etc/modprobe.d
  echo "options nvidia_drm modeset=1 fbdev=1" > /etc/modprobe.d/nvidia.conf
fi
EOF

# ── Bootloader ────────────────────────────────────────────────
header "Bootloader (systemd-boot)"

arch-chroot /mnt bootctl install

mkdir -p /mnt/boot/loader/entries

cat > /mnt/boot/loader/loader.conf <<'EOF'
default  arch.conf
timeout  4
console-mode max
editor   no
EOF

ROOT_UUID=$(blkid -s PARTUUID -o value "$ROOT_PART")

# Build kernel cmdline
CMDLINE="root=PARTUUID=$ROOT_UUID rw quiet"
if [[ "$FILESYSTEM" == "btrfs" ]]; then
  CMDLINE="$CMDLINE rootflags=subvol=@"
fi
if [[ "$GPU" == "nvidia" ]]; then
  CMDLINE="$CMDLINE nvidia_drm.modeset=1"
fi

UCODE=""
lscpu | grep -qi "intel" && UCODE="intel-ucode.img" || UCODE="amd-ucode.img"

cat > /mnt/boot/loader/entries/arch.conf <<EOF
title   $HOSTNAME
linux   /vmlinuz-$KERNEL
initrd  /$UCODE
initrd  /initramfs-$KERNEL.img
options $CMDLINE
EOF

# Fallback entry
cp /mnt/boot/loader/entries/arch.conf /mnt/boot/loader/entries/arch-fallback.conf
sed -i 's/initramfs-.*\.img/initramfs-linux-fallback.img/' /mnt/boot/loader/entries/arch-fallback.conf
sed -i 's|^title .*|title Fallback|' /mnt/boot/loader/entries/arch-fallback.conf

# ── AUR helper + chezmoi ─────────────────────────────────────
header "User setup: AUR + dotfiles"

arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

# Install AUR helper
su $USERNAME -c "cd /home/$USERNAME && git clone https://aur.archlinux.org/$AUR_HELPER-bin.git"
su $USERNAME -c "cd /home/$USERNAME/$AUR_HELPER-bin && makepkg -si --noconfirm"
rm -rf "/home/$USERNAME/$AUR_HELPER-bin"

# Install chezmoi
if [[ "$CHEZMOI_INSTALL" == "aur" ]]; then
  su $USERNAME -c "$AUR_HELPER -S --noconfirm chezmoi"
elif [[ "$CHEZMOI_INSTALL" == "binary" ]]; then
  su $USERNAME -c "sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- -b /home/$USERNAME/.local/bin"
  echo 'export PATH=\$HOME/.local/bin:\$PATH' >> /home/$USERNAME/.bash_profile
fi

# Apply dotfiles
su $USERNAME -c "chezmoi init --apply $DOTFILES_REPO" || warn "chezmoi init failed — you can run it manually after reboot"
EOF

# ── Post-install AUR packages ────────────────────────────────
if [[ -f "./packages-aur.txt" ]]; then
  header "Installing AUR packages"
  cp "./packages-aur.txt" "/mnt/home/$USERNAME/packages-aur.txt"
  arch-chroot /mnt /bin/bash <<EOF
  su $USERNAME -c "$AUR_HELPER -S --noconfirm --needed \$(cat /home/$USERNAME/packages-aur.txt)"
  rm /home/$USERNAME/packages-aur.txt
EOF
fi

# ── Finalize ──────────────────────────────────────────────────
header "Finalizing"

info "Setting up swap in fstab"
if [[ "$FILESYSTEM" == "btrfs" ]]; then
  echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
fi

info "Installation complete!"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo "  1. Review:  cat /mnt/etc/fstab"
echo "  2. Chroot if needed:  arch-chroot /mnt"
echo "  3. Reboot:  umount -R /mnt && reboot"
echo ""
echo -e "  ${BOLD}After reboot:${NC}"
echo "  - Login as $USERNAME"
echo "  - Start Hyprland:  Hyprland"
echo "  - Or use SDDM:  sudo systemctl enable --now sddm"
echo ""
