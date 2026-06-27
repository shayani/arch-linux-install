run_preflight() {
  header "Pre-flight checks"

  info "Checking root privileges..."
  [[ $EUID -eq 0 ]] || err "This script must be run as root"
  info "✓ Root"

  info "Checking UEFI mode..."
  [[ -d /sys/firmware/efi ]] || err "This script supports UEFI only"
  info "✓ UEFI"

  info "Checking internet connection..."
  if curl -s --connect-timeout 5 https://archlinux.org >/dev/null 2>&1; then
    info "✓ Internet"
  elif ping -c1 -W3 archlinux.org &>/dev/null; then
    info "✓ Internet (via ping)"
  else
    err "No internet connection. Run: dhcpcd"
  fi

  # Detect disk interactively if not set
  if [[ -z "$DISK" ]]; then
    echo ""
    lsblk -dno NAME,SIZE,MODEL | awk '{print "  /dev/"$0}'
    echo ""
    read -rp "Target disk (e.g. /dev/nvme0n1): " DISK
    [[ -b "$DISK" ]] || err "Invalid disk: $DISK"
  else
    info "Disk: $DISK"
  fi

  # Detect GPU
  info "Detecting GPU..."
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
  fi
  info "✓ GPU: ${GPU}"
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
