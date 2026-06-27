build_package_list() {
  PACKAGES=(
    base base-devel
    "$KERNEL" "$KERNEL-headers" linux-firmware
    "$(lscpu | grep -qi "intel" && echo "intel-ucode" || echo "amd-ucode")"
    btrfs-progs dosfstools
    sudo nano vim git curl wget rsync
    networkmanager nm-connection-editor
    pipewire pipewire-pulse pipewire-alsa wireplumber
    sof-firmware alsa-utils
    hyprland waybar rofi-wayland alacritty
    hyprlauncher
    dunst libnotify
    thunar thunar-archive-plugin file-roller
    ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-font-awesome
    hyprpolkitagent xdg-desktop-portal-hyprland
    qt5-wayland qt6-wayland
    brightnessctl pavucontrol
    bluetui
    power-profiles-daemon
    grim slurp swappy
    wl-clipboard cliphist
    swaylock swayidle
    bluez bluez-utils
    docker docker-compose
    man-db man-pages
  )

  if [[ "$FILESYSTEM" == "btrfs" ]]; then
    PACKAGES+=(snapper snap-pac)
  fi

  if [[ "$GPU" == "nvidia" ]]; then
    PACKAGES+=(nvidia-dkms nvidia-settings nvidia-utils libva-nvidia-driver)
  fi
}

run_pacstrap() {
  header "Installing base system"
  info "Installing packages (this may take a while)"
  pacstrap -K /mnt "${PACKAGES[@]}"

  header "Generating fstab"
  genfstab -U /mnt >> /mnt/etc/fstab
  info "/mnt/etc/fstab:"
  cat /mnt/etc/fstab
}

run_chroot_config() {
  header "System configuration"

  arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

sed -i 's/^#$LOCALE/$LOCALE/' /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname

cat > /etc/hosts <<-HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS

if [[ "$GPU" == "nvidia" ]]; then
  sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
fi
if [[ "$FILESYSTEM" == "btrfs" ]]; then
  sed -i 's/^HOOKS=(base udev/HOOKS=(base udev btrfs /' /etc/mkinitcpio.conf
fi
mkinitcpio -P

echo "root:$PASSWORD" | chpasswd

useradd -m -G wheel,audio,video,storage,optical,docker -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable docker
systemctl enable power-profiles-daemon
systemctl enable fstrim.timer

if [[ "$GPU" == "nvidia" ]]; then
  mkdir -p /etc/modprobe.d
  echo "options nvidia_drm modeset=1 fbdev=1" > /etc/modprobe.d/nvidia.conf
fi
EOF
}
