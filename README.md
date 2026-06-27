# Arch Linux + Hyprland Installer

Automatic Arch Linux installation with Hyprland, chezmoi dotfiles, and btrfs snapshots.

## Quick start

Boot the official Arch ISO, connect to the internet, then:

```bash
curl -fsSL https://raw.githubusercontent.com/shayani/arch-linux-install/main/install.sh | bash
```

## Usage with custom config

```bash
curl -LO https://raw.githubusercontent.com/shayani/arch-linux-install/main/config.example.sh
cp config.example.sh config.sh
nano config.sh          # edit disk, hostname, etc
CONFIG_FILE=./config.sh bash <(curl -fsSL https://raw.githubusercontent.com/shayani/arch-linux-install/main/install.sh)
```

## Features

- UEFI + GPT
- Btrfs with subvolumes (`@`, `@home`, `@snapshots`, `@var_log`, `@cache`)
- Swapfile on btrfs
- systemd-boot
- GPU detection (AMD/Intel/NVIDIA)
- NVIDIA: DRM mode-setting, nvidia-dkms
- Hyprland + Wayland stack (pipewire, wireplumber)
- AUR helper (paru)
- chezmoi dotfiles bootstrap
- Snapper + snap-pac for snapshots

## Post-install

```bash
# Start Hyprland
Hyprland

# Or install a login manager
sudo systemctl enable --now sddm
```

## Customization

Edit `config.sh` before running. Key variables:

| Variable | Default | Description |
|---|---|---|
| `DISK` | (prompt) | Target disk, e.g. `/dev/nvme0n1` |
| `HOSTNAME` | `arch` | Machine hostname |
| `USERNAME` | `shayani` | Primary user |
| `KERNEL` | `linux` | Kernel: `linux`, `linux-zen`, `linux-lts` |
| `GPU` | `auto` | `auto`, `amd`, `intel`, `nvidia` |
| `FILESYSTEM` | `btrfs` | `btrfs` or `ext4` |
| `SWAP_SIZE` | `4G` | Swapfile size |
| `DOTFILES_REPO` | chezmoi repo | Dotfiles to apply |
