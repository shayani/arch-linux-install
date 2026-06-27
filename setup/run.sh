#!/usr/bin/env bash
# run.sh - Pós-instalação Arch Workstation
# Executa cada módulo em ordem. Se um falhar, corrija e rode novamente.
# Uso: sudo bash run.sh [NÚMERO]
#   sudo bash run.sh          # executa todos
#   sudo bash run.sh 50       # executa só o 50-aur.sh
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
source "$DIR/lib.sh"

header "Pós-instalação Arch Workstation"
echo "Usuário: $USER"

FILTER="${1:-}"

for script in "$DIR"/[0-9][0-9]-*.sh; do
  name=$(basename "$script")
  num=${name:0:2}

  # Se passou um filtro, executa só aquele
  [[ -n "$FILTER" ]] && [[ "$num" != "$FILTER" ]] && continue

  echo ""
  echo -e "${BOLD}▸ $name${NC}"
  if bash "$script"; then
    ok "$name concluído"
  else
    warn "$name FALHOU — corrija e rode: sudo bash run.sh $num"
  fi
done

echo ""
header "Concluído!"
echo "Reinicie e inicie o Hyprland com: Hyprland"
