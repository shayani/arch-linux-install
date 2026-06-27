RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
header(){ echo -e "\n${BOLD}━━━ $1 ━━━${NC}\n"; }

load_config() {
  CONFIG_FILE="${CONFIG_FILE:-./config.sh}"
  if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    info "Config loaded from $CONFIG_FILE"
  fi
}

set_defaults() {
  DISK="${DISK:-}"
  HOSTNAME="${HOSTNAME:-arch}"
  USERNAME="${USERNAME:-shayani}"
  PASSWORD="${PASSWORD:-}"
  TIMEZONE="${TIMEZONE:-America/Sao_Paulo}"
  LOCALE="${LOCALE:-pt_BR.UTF-8}"
  KEYMAP="${KEYMAP:-br-abnt2}"
  KERNEL="${KERNEL:-linux}"
  FILESYSTEM="${FILESYSTEM:-btrfs}"
  SWAP_SIZE="${SWAP_SIZE:-4G}"
  GPU="${GPU:-auto}"
  AUR_HELPER="${AUR_HELPER:-yay}"
  DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/shayani/dotfiles.git}"
  CHEZMOI_INSTALL="${CHEZMOI_INSTALL:-aur}"
}
