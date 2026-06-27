#!/usr/bin/env bash
# Continua a instalação: AUR helper + chezmoi + AUR packages
set -euo pipefail

echo "=== Montando sistema instalado ==="
mount /dev/vda2 /mnt 2>/dev/null || true
mount --mkdir /dev/vda1 /mnt/boot 2>/dev/null || true
mount -o subvol=@ /dev/vda2 /mnt 2>/dev/null || true

arch-chroot /mnt /bin/bash <<'CHROOT'
set -euo pipefail

echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "=== Instalando paru-bin ==="
su - shayani -c "
  cd /home/shayani
  git clone https://aur.archlinux.org/paru-bin.git
  cd paru-bin && makepkg -si --noconfirm
"
rm -rf /home/shayani/paru-bin

echo "=== Chezmoi ==="
su - shayani -c "
  curl -fsLS get.chezmoi.io | sh -s -- -b /home/shayani/.local/bin
  echo 'export PATH=\$HOME/.local/bin:\$PATH' >> /home/shayani/.bash_profile
  /home/shayani/.local/bin/chezmoi init --apply https://github.com/shayani/dotfiles.git
" || true

echo "=== Pacotes AUR ==="
if [[ -f /home/shayani/packages-aur.txt ]]; then
  su - shayani -c "paru -S --noconfirm --needed \$(cat /home/shayani/packages-aur.txt)" || true
fi

echo ""
echo "✓ Finalizado! Desmonte com: umount -R /mnt"
CHROOT
