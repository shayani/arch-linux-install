run_bootloader() {
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

  cp /mnt/boot/loader/entries/arch.conf /mnt/boot/loader/entries/arch-fallback.conf
  sed -i 's/initramfs-.*\.img/initramfs-linux-fallback.img/' /mnt/boot/loader/entries/arch-fallback.conf
  sed -i 's|^title .*|title Fallback|' /mnt/boot/loader/entries/arch-fallback.conf
}
