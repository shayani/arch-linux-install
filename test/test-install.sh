#!/usr/bin/env bash
set -euo pipefail

# Test the modular install.sh inside Docker
# Usage: docker run --rm -v $(pwd):/install archlinux:latest bash /install/test/test-install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
for module in helpers preflight disk system user bootloader finalize; do
  source "$SCRIPT_DIR/lib/${module}.sh"
done

export DISK="/dev/null"  # won't be used in --skip-disk mode
export GPU="amd"
export PASSWORD="test123"
export HOSTNAME="arch-test"
export USERNAME="shayani"
export TIMEZONE="America/Sao_Paulo"
export LOCALE="pt_BR.UTF-8"
export KEYMAP="br-abnt2"
export FILESYSTEM="ext4"
export SKIP_DISK=true

set_defaults

echo "=== 1. build_package_list ==="
build_package_list
echo "Packages: ${#PACKAGES[@]}"

echo "=== 2. Simulating chroot config ==="
echo "$HOSTNAME" > /etc/hostname
echo "root:$PASSWORD" | chpasswd
id "$USERNAME" &>/dev/null || useradd -m -G wheel,audio,video,storage,optical,docker -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "=== 3. Validation ==="
echo "User $(id shayani)"
echo "Groups: $(groups shayani)"
echo "Docker: $(docker --version)"
echo "Waybar: $(waybar --version)"
echo "Hostname: $(cat /etc/hostname)"

echo ""
echo "=== All tests passed ==="
