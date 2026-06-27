#!/usr/bin/env bash
# run.sh - Executa todos os módulos em ordem
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd)
source "$DIR/lib.sh"

header "Pós-instalação Arch Workstation"
echo "Usuário: $USER"
echo ""

for script in "$DIR"/[0-9][0-9]-*.sh; do
  name=$(basename "$script")
  echo -e "${BOLD}▶ $name${NC}"
  bash "$script" 2>&1 | tail -1
  echo ""
done

header "Concluído!"
echo "Reinicie e inicie o Hyprland com: Hyprland"
