#!/usr/bin/env bash
set -euo pipefail

SKIP_DISK=false
for arg in "$@"; do
  case "$arg" in
    --skip-disk) SKIP_DISK=true ;;
    --help|-h)
      echo "Usage: bash install.sh [--skip-disk]"
      echo ""
      echo "  --skip-disk    Skip partitioning and formatting (for testing)"
      exit 0
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
for module in helpers preflight disk system user bootloader finalize; do
  source "$SCRIPT_DIR/lib/${module}.sh"
done

load_config
set_defaults

if [[ "$SKIP_DISK" == false ]]; then
  run_preflight
  prompt_password
  derive_partition_paths
  run_partition
  run_filesystem
else
  info "Skip-disk mode: assuming /mnt is already prepared"
  info "Set DISK, GPU, PASSWORD via config.sh or env vars"
fi

build_package_list
run_pacstrap
run_chroot_config
run_bootloader
run_aur_chezmoi
run_aur_packages
run_finalize
