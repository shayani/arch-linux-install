#!/usr/bin/env bash
# lib.sh - Funções compartilhadas
[[ -z "${_LIB_SH_:-}" ]] || return 0; _LIB_SH_=1

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
ok()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
header(){ echo -e "\n${BOLD}━━━ $1 ━━━${NC}\n"; }

USER="${SUDO_USER:-${USER:-shayani}}"

pacotes() {
  local missing=()
  for pkg in "$@"; do
    pacman -Q "$pkg" &>/dev/null || missing+=("$pkg")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    pacman -S --noconfirm --needed "${missing[@]}"
    ok "${#missing[@]} pacotes instalados"
  else
    ok "todos já instalados"
  fi
}

servicos() {
  for svc in "$@"; do
    systemctl enable --now "$svc" 2>/dev/null && ok "$svc ativo" || warn "$svc falhou"
  done
}
