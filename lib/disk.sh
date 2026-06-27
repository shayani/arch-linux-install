run_partition() {
  header "Partitioning $DISK"

  info "Wiping existing partition table"
  wipefs -af "$DISK" &>/dev/null || true

  info "Creating GPT partition table and partitions"
  parted "$DISK" -- mklabel gpt
  parted "$DISK" -- mkpart ESP fat32 1MiB 1024MiB
  parted "$DISK" -- set 1 esp on
  parted "$DISK" -- mkpart primary 1024MiB 100%

  sleep 1
  partprobe "$DISK" 2>/dev/null || true
  sleep 1

  info "Formatting EFI partition"
  mkfs.fat -F32 "$EFI_PART"
}

run_filesystem() {
  if [[ "$FILESYSTEM" == "btrfs" ]]; then
    setup_btrfs
  else
    setup_ext4
  fi

  info "Mounting EFI partition"
  mount --mkdir "$EFI_PART" "$EFI_MOUNT"
}

setup_btrfs() {
  header "Btrfs setup"

  info "Formatting root partition as btrfs"
  mkfs.btrfs "$ROOT_PART" -f

  info "Mounting root partition to create subvolumes"
  mount "$ROOT_PART" /mnt

  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@snapshots
  btrfs subvolume create /mnt/@var_log
  btrfs subvolume create /mnt/@cache

  umount /mnt

  MOUNT_OPTS="compress=zstd:3,noatime"

  info "Mounting subvolumes"
  mount -o "$MOUNT_OPTS",subvol=@ "$ROOT_PART" /mnt
  mount --mkdir -o "$MOUNT_OPTS",subvol=@home "$ROOT_PART" /mnt/home
  mount --mkdir -o "$MOUNT_OPTS",subvol=@snapshots "$ROOT_PART" /mnt/.snapshots
  mount --mkdir -o "$MOUNT_OPTS",subvol=@var_log "$ROOT_PART" /mnt/var/log
  mount --mkdir -o "$MOUNT_OPTS",subvol=@cache "$ROOT_PART" /mnt/var/cache

  create_swapfile
}

setup_ext4() {
  header "ext4 setup"

  info "Formatting root partition as ext4"
  mkfs.ext4 "$ROOT_PART"

  mount "$ROOT_PART" /mnt
}

create_swapfile() {
  info "Creating swapfile ($SWAP_SIZE)"
  truncate -s 0 /mnt/swapfile
  chattr +C /mnt/swapfile
  fallocate -l "$SWAP_SIZE" /mnt/swapfile
  chmod 0600 /mnt/swapfile
  mkswap /mnt/swapfile
}
