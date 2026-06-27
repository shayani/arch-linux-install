#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${1:-arch-install-test}"
RAM="${2:-4096}"
CPUS="${3:-2}"
DISK_SIZE="${4:-20G}"
ISO="${5:-/tmp/archlinux.iso}"
CONNECT="qemu:///system"

echo "=== Creating VM: $VM_NAME ==="
echo "  RAM: $RAM | CPUs: $CPUS | Disk: $DISK_SIZE"
echo ""

# Ensure libvirtd is running
if ! systemctl is-active --quiet libvirtd; then
  echo "Starting libvirtd..."
  systemctl start libvirtd
fi

# Download Arch ISO if not present
if [[ ! -f "$ISO" ]]; then
  echo "Downloading Arch Linux ISO..."
  curl -fsSLo "$ISO" "https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
fi

# Check if VM already exists
if virsh -c "$CONNECT" dominfo "$VM_NAME" &>/dev/null; then
  echo "VM $VM_NAME already exists."
  echo "  Start:  virsh -c $CONNECT start $VM_NAME"
  echo "  Console: virsh -c $CONNECT console $VM_NAME"
  echo "  Delete:  virsh -c $CONNECT undefine $VM_NAME --nvram --remove-all-storage"
  exit 0
fi

# Detect if we have a graphical session
if [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  GRAPHICS="spice,port=5900,listen=0.0.0.0"
  EXTRA="--video virtio --serial pty"
else
  GRAPHICS="none"
  EXTRA="--serial pty"
fi

echo "Starting VM..."
virt-install \
  --connect "$CONNECT" \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$CPUS" \
  --disk path=/var/lib/libvirt/images/${VM_NAME}.qcow2,size=$DISK_SIZE,format=qcow2,sparse=true \
  --cdrom "$ISO" \
  --os-variant archlinux \
  --network network=default \
  --graphics "$GRAPHICS" \
  --boot uefi \
  $EXTRA

echo ""
echo "=== VM created ==="
echo "To connect:"
echo "  spicy -h 127.0.0.1 -p 5900"
echo "To stop:"
echo "  virsh -c $CONNECT destroy $VM_NAME"
echo "To delete:"
echo "  virsh -c $CONNECT undefine $VM_NAME --nvram --remove-all-storage"