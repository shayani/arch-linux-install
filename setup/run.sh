#!/usr/bin/env bash
# run.sh - Pós-instalação Arch Workstation
# Uso: sudo bash run.sh [NUMERO]
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
source "$DIR/lib.sh"

clear 2>/dev/null || true
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Pós-instalação Arch Workstation${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  Usuário: $USER"
echo ""

FILTER="${1:-}"

for script in "$DIR"/[0-9][0-9]-*.sh; do
  name=$(basename "$script")
  num=${name:0:2}

  [[ -n "$FILTER" ]] && [[ "$num" != "$FILTER" ]] && continue

  echo ""
  echo -e "${BOLD}▸ $name${NC}"
  echo -e "${BOLD}  $(printf '=%.0s' {1..50})${NC}"
  
  if bash "$script"; then
    ok "$name finalizado"
  else
    echo -e "${YELLOW}  └─ $name FALHOU ─ corrija e rode: sudo bash run.sh $num${NC}"
  fi
done

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Concluído! Reinicie e inicie Hyprland${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
