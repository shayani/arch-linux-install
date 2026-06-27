FROM archlinux:latest

# Install all packages from the installer script
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm \
  base base-devel \
  linux linux-headers linux-firmware \
  amd-ucode \
  btrfs-progs dosfstools \
  sudo nano vim git curl wget rsync \
  networkmanager \
  pipewire pipewire-pulse pipewire-alsa wireplumber \
  sof-firmware alsa-utils \
  hyprland waybar rofi-wayland alacritty \
  hyprlauncher \
  dunst libnotify \
  thunar thunar-archive-plugin file-roller \
  ttf-jetbrains-mono-nerd noto-fonts-emoji \
  polkit-kde-agent xdg-desktop-portal-hyprland \
  qt5-wayland qt6-wayland \
  brightnessctl pavucontrol \
  bluetui power-profiles-daemon \
  grim slurp swappy \
  wl-clipboard cliphist \
  swaylock swayidle \
  bluez bluez-utils \
  docker docker-compose \
  man-db man-pages \
  snapper snap-pac

# Test user + sudo + groups (same as lib/system.sh)
RUN useradd -m -G wheel,audio,video,storage,optical,docker -s /bin/bash shayani && \
  echo "shayani:test123" | chpasswd && \
  echo "root:test123" | chpasswd && \
  echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Test services enable (same as lib/system.sh)
RUN systemctl enable NetworkManager 2>/dev/null; \
  systemctl enable bluetooth 2>/dev/null; \
  systemctl enable docker 2>/dev/null; \
  systemctl enable fstrim.timer 2>/dev/null; \
  echo "Services enabled"

# Test locale and timezone (same as lib/system.sh)
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
  echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen && \
  echo "LANG=pt_BR.UTF-8" > /etc/locale.conf && \
  echo "KEYMAP=br-abnt2" > /etc/vconsole.conf && \
  echo "arch-test" > /etc/hostname

# Validate
RUN export XDG_RUNTIME_DIR=/tmp/runtime && \
  docker --version && \
  waybar --version && \
  echo "All validations passed"
