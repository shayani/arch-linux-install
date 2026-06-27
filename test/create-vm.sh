#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${1:-arch-install-test}"
RAM="${2:-4096}"
CPUS="${3:-2}"
DISK_SIZE="${4:-20G}"
ISO="${5:-/tmp/archlinux.iso}"

echo "=== Creating VM: $VM_NAME ==="
echo "  RAM: $RAM | CPUs: $CPUS | Disk: $DISK_SIZE"
echo ""

# Ensure libvirtd is running
if ! systemctl is-active --quiet libvirtd; then
  echo "Starting libvirtd..."
  sudo systemctl start libvirtd
fi

# Download Arch ISO if not present
if [[ ! -f "$ISO" ]]; then
  echo "Downloading Arch Linux ISO..."
  curl -fsSLo "$ISO" "https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
fi

# Create disk image
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
if [[ ! -f "$DISK_PATH" ]]; then
  echo "Creating disk image ($DISK_SIZE)..."
  sudo qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"
fi

# Check if VM already exists
if virsh dominfo "$VM_NAME" &>/dev/null; then
  echo "VM $VM_NAME already exists."
  echo "  Start:  virsh start $VM_NAME"
  echo "  Console: virsh console $VM_NAME"
  echo "  Viewer:  virt-viewer $VM_NAME"
  exit 0
fi

# Detect if we have a graphical session (for virt-viewer)
if [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  GRAPHICS="spice"
  VIDEO="virtio"
  EXTRA="--video virtio"
else
  GRAPHICS="none"
  VIDEO=""
  EXTRA="--console pty,target_type=serial --serial pty"
fi

echo "Starting VM..."
sudo virt-install \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$CPUS" \
  --disk path="$DISK_PATH",format=qcow2 \
  --cdrom "$ISO" \
  --os-variant archlinux \
  --network network=default \
  --graphics "$GRAPHICS" \
  $EXTRA

echo ""
echo "=== VM created ==="
echo "To connect:"
if [[ "$GRAPHICS" == "spice" ]]; then
  echo "  virt-viewer $VM_NAME"
  echo "Or via SSH: virsh console $VM_NAME"
else
  echo "  virsh console $VM_NAME"
fi
echo "To stop:"
echo "  virsh destroy $VM_NAME"
echo "To delete:"
echo "  virsh undefine $VM_NAME --remove-all-storage"
