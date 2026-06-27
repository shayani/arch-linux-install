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
nano config.sh
CONFIG_FILE=./config.sh bash install.sh
```

## Test mode (skip disk operations)

```bash
# Test the chroot/configuration parts without a real disk
bash install.sh --skip-disk
```

Or in Docker:

```bash
docker build -t arch-install-test test/
docker run --rm -v $(pwd):/install arch-install-test bash /install/test/test-install.sh
```

## Project structure

```
install.sh              # Orchestrator (--skip-disk for testing)
config.sh               # User configuration (gitignored)
config.example.sh       # Example config
lib/
├── helpers.sh           # Colors, logging, defaults
├── preflight.sh         # Root/UEFI/network checks, GPU detection
├── disk.sh              # Partitioning, btrfs subvolumes, mounting
├── system.sh            # Packages, pacstrap, chroot config
├── user.sh              # AUR helper, chezmoi, dotfiles
├── bootloader.sh        # systemd-boot installation
└── finalize.sh          # fstab, swap, finish message
test/
├── Dockerfile           # Builds a test environment with all packages
└── test-install.sh      # Validates the lib modules
packages-system.txt      # Reference: official repo packages
packages-aur.txt         # AUR packages to install after chezmoi
```

## Features

- UEFI + GPT
- Btrfs with subvolumes (`@`, `@home`, `@snapshots`, `@var_log`, `@cache`)
- Swapfile on btrfs
- systemd-boot
- GPU detection (AMD/Intel/NVIDIA)
- NVIDIA: DRM mode-setting, nvidia-dkms
- Hyprland + Wayland stack (pipewire, wireplumber)
- AUR helper (yay)
- Docker + docker-compose
- chezmoi dotfiles bootstrap
- Snapper + snap-pac for snapshots

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
| `AUR_HELPER` | `yay` | `yay` or `paru` |
| `DOTFILES_REPO` | chezmoi repo | Dotfiles to apply |
