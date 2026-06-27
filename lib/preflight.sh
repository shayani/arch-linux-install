run_preflight() {
  header "Pre-flight checks"

  [[ $EUID -eq 0 ]] || err "This script must be run as root"
  [[ -d /sys/firmware/efi ]] || err "This script supports UEFI only"
  ping -c1 -W2 archlinux.org &>/dev/null || err "No internet connection"

  # Detect disk interactively if not set
  if [[ -z "$DISK" ]]; then
    echo ""
    lsblk -dno NAME,SIZE,MODEL | awk '{print "  /dev/"$0}'
    echo ""
    read -rp "Target disk (e.g. /dev/nvme0n1): " DISK
    [[ -b "$DISK" ]] || err "Invalid disk: $DISK"
  fi

  # Detect GPU
  if [[ "$GPU" == "auto" ]]; then
    if lspci | grep -qi "nvidia"; then
      GPU="nvidia"
    elif lspci | grep -qi "amd.*graphics"; then
      GPU="amd"
    elif lspci | grep -qi "intel.*graphics"; then
      GPU="intel"
    else
      GPU="amd"
    fi
    info "Detected GPU: ${GPU}"
  fi
}

prompt_password() {
  if [[ -z "$PASSWORD" ]]; then
    while true; do
      read -rsp "Password for root + $USERNAME: " PASSWORD; echo
      read -rsp "Confirm password: " PASSWORD2; echo
      [[ "$PASSWORD" == "$PASSWORD2" ]] && break
      warn "Passwords do not match, try again"
    done
  fi
}

derive_partition_paths() {
  if echo "$DISK" | grep -q "nvme"; then
    PART_PREFIX="${DISK}p"
  elif echo "$DISK" | grep -q "mmcblk"; then
    PART_PREFIX="${DISK}p"
  else
    PART_PREFIX="${DISK}"
  fi
  EFI_PART="${PART_PREFIX}1"
  ROOT_PART="${PART_PREFIX}2"
  EFI_MOUNT="/mnt/boot"
}
