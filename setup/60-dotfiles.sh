#!/usr/bin/env bash
# 60-dotfiles.sh - Chezmoi + dotfiles
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Dotfiles (chezmoi)"
if ! command -v chezmoi &>/dev/null; then
  sudo -u "$USER" sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/$USER/.local/bin
  echo 'export PATH=$HOME/.local/bin:$PATH' >> /home/$USER/.bash_profile
fi
sudo -u "$USER" /home/$USER/.local/bin/chezmoi init --apply https://github.com/shayani/dotfiles.git 2>/dev/null ||   warn "chezmoi init falhou — rode manualmente"
