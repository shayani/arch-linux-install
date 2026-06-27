run_aur_chezmoi() {
  header "User setup: AUR + dotfiles"

  arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

# Allow passwordless sudo for AUR installation
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

su $USERNAME -c "cd /home/$USERNAME && git clone https://aur.archlinux.org/$AUR_HELPER-bin.git"
su $USERNAME -c "cd /home/$USERNAME/$AUR_HELPER-bin && makepkg -si --noconfirm"
rm -rf "/home/$USERNAME/$AUR_HELPER-bin"

if [[ "$CHEZMOI_INSTALL" == "aur" ]]; then
  su $USERNAME -c "$AUR_HELPER -S --noconfirm chezmoi"
elif [[ "$CHEZMOI_INSTALL" == "binary" ]]; then
  su $USERNAME -c "sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- -b /home/$USERNAME/.local/bin"
  echo 'export PATH=\$HOME/.local/bin:\$PATH' >> /home/$USERNAME/.bash_profile
fi

su $USERNAME -c "chezmoi init --apply $DOTFILES_REPO" || warn "chezmoi init failed — you can run it manually after reboot"
EOF
}

run_aur_packages() {
  if [[ -f "./packages-aur.txt" ]]; then
    header "Installing AUR packages"
    cp "./packages-aur.txt" "/mnt/home/$USERNAME/packages-aur.txt"
    arch-chroot /mnt /bin/bash <<EOF
    su $USERNAME -c "$AUR_HELPER -S --noconfirm --needed \$(cat /home/$USERNAME/packages-aur.txt)"
    rm /home/$USERNAME/packages-aur.txt
EOF
  fi
}
