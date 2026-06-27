#!/usr/bin/env bash
# run-dialog.sh - Interface ncurses para pós-instalação
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
source "$DIR/lib.sh"

# Strip ANSI escape codes for dialog display
strip_ansi() {
  sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g'
}

# Garantir que dialog está instalado
if ! command -v dialog &>/dev/null; then
  echo "Instalando dialog para interface gráfica..."
  pacman -S --noconfirm dialog
fi

clear
dialog --title "Arch Workstation Setup" \
  --infobox "Bem-vindo à configuração do seu Arch Workstation!\n\nUsuário: $USER\n\nPressione ENTER para continuar..." \
  8 50
read -r

STEPS=(
  "05-pacman"    "Configurar pacman (ILoveCandy, parallel downloads)"
  "10-base"      "Pacotes base (áudio, firmware, git, utilidades)"
  "20-hyprland"  "Hyprland + Wayland + apps"
  "30-bluetooth" "Bluetooth (bluez, bluetui)"
  "40-docker"    "Docker + Docker Compose"
  "50-aur"       "AUR helper (paru) + pacotes AUR"
  "60-dotfiles"  "Chezmoi + dotfiles"
  "70-services"  "Ativar serviços (NetworkManager, power-profiles)"
  "99-cleanup"   "Ajustes finais (swapfile)"
)

TOTAL=${#STEPS[@]}

for ((i=0; i<TOTAL; i+=2)); do
  num="${STEPS[$i]}"
  label="${STEPS[$i+1]}"
  percent=$(( (i/2) * 100 / (TOTAL/2) ))

  # Gauge de progresso geral
  echo "$percent" | dialog --title "Arch Workstation Setup" \
    --gauge "Passo $((i/2 + 1)) de $((TOTAL/2)): $label\n\nExecutando $num.sh..." \
    8 60 0

  # Executa o script e captura saída
  script="$DIR/${num}.sh"
  if [[ -f "$script" ]]; then
    output=$(bash "$script" 2>&1)
    exitcode=$?
  else
    output="Script não encontrado: $script"
    exitcode=1
  fi

  if [[ $exitcode -eq 0 ]]; then
    dialog --title "✓ $num" --msgbox "$(echo "$output" | strip_ansi | tail -5)" 10 60
  else
    dialog --title "✗ $num - FALHOU" --msgbox "$(echo "$output" | strip_ansi | tail -10)\n\nExecute novamente: sudo bash run-dialog.sh $num" 12 60
    exit 1
  fi
done

dialog --title "Concluído!" \
  --msgbox "Pós-instalação finalizada!\n\nReinicie o sistema e inicie o Hyprland." \
  8 40
clear
