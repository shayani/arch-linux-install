#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${1:-arch-install-test}"
RAM="${2:-4096}"
CPUS="${3:-2}"
DISK_SIZE="${4:-20G}"
ISO="${5:-/tmp/archlinux.iso}"

echo "=== Creating VM: $VM_NAME ==="

# Download Arch ISO if not present
if [[ ! -f "$ISO" ]]; then
  echo "Downloading Arch Linux ISO..."
  curl -fsSLo "$ISO" "https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
fi

# Create disk image
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
if [[ ! -f "$DISK_PATH" ]]; then
  echo "Creating disk image ($DISK_SIZE)..."
  echo joesmith | sudo -S qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"
fi

# Check if VM already exists
if virsh dominfo "$VM_NAME" &>/dev/null; then
  echo "VM $VM_NAME already exists, starting it..."
  virsh start "$VM_NAME"
  virsh console "$VM_NAME"
  exit 0
fi

# Create VM with virt-install
echo "Starting VM (console will attach)..."
echo joesmith | sudo -S virt-install \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$CPUS" \
  --disk path="$DISK_PATH",format=qcow2 \
  --cdrom "$ISO" \
  --os-variant archlinux \
  --network network=default \
  --graphics none \
  --console pty,target_type=serial \
  --serial pty

echo ""
echo "VM created. To connect:"
echo "  virsh console $VM_NAME"
echo "To stop:"
echo "  virsh destroy $VM_NAME"
echo "To delete:"
echo "  virsh undefine $VM_NAME --remove-all-storage"
