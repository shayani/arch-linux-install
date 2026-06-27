run_finalize() {
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
}
