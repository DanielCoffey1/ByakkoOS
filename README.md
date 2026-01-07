# Arch Linux System Replication Script

Automated script to replicate my Arch Linux system configuration on a fresh installation. This script installs all packages, configures services, detects hardware, installs appropriate drivers, and applies dotfiles from my [byakko-theme](https://github.com/DanielCoffey1/byakko-theme) repository.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [What This Script Does](#what-this-script-does)
- [Hardware Detection](#hardware-detection)
- [Package Lists](#package-lists)
- [Services Configured](#services-configured)
- [Dotfiles Deployment](#dotfiles-deployment)
- [Post-Installation](#post-installation)
- [Troubleshooting](#troubleshooting)

## Overview

This script automates the complete setup of my Arch Linux environment, including:
- 166 official repository packages
- 26 AUR packages
- Automatic hardware detection and driver installation
- System service configuration
- Dotfiles from byakko-theme repository

## Features

- **Automatic Hardware Detection**: Detects CPU (Intel/AMD) and GPU (NVIDIA/AMD/Intel) and installs appropriate drivers
- **Safe Installation**: Uses `--needed` flag to skip already-installed packages
- **Colored Output**: Easy-to-read status messages during installation
- **Backup System**: Automatically backs up existing configurations before applying dotfiles
- **Error Handling**: Stops on errors to prevent partial installations
- **Service Management**: Enables and starts all necessary system services

## Prerequisites

- Fresh Arch Linux installation with base system
- Internet connection
- User with sudo privileges
- NOT running as root

## Usage

1. Download the script to your home directory:
```bash
curl -O https://raw.githubusercontent.com/[your-username]/[your-repo]/main/arch-setup.sh
chmod +x arch-setup.sh
```

2. Run the script:
```bash
./arch-setup.sh
```

3. The script will prompt for your sudo password when needed
4. For package conflicts, you'll be asked to confirm replacements
5. After completion, reboot your system

## What This Script Does

### 1. System Update
```bash
sudo pacman -Syu --noconfirm
```
Updates all existing packages to their latest versions.

### 2. Base Development Tools
Installs `base-devel` and `git` (required for building AUR packages).

### 3. AUR Helper Installation
Installs `yay` if not already present:
- Clones yay from AUR
- Builds and installs yay
- Used for all subsequent AUR package installations

### 4. Hardware Detection
Automatically detects:
- **CPU Vendor**: Intel or AMD (using `lscpu`)
- **GPU Vendor**: NVIDIA, AMD, or Intel (using `lspci`)

### 5. Package Installation
Installs packages in this order:
1. Official repository packages (166 packages)
2. CPU microcode (Intel or AMD based on detection)
3. GPU drivers (NVIDIA, AMD, or Intel based on detection)
4. AUR packages (26 packages)

### 6. Service Configuration
Enables and starts system services:
- Docker
- CUPS (printing)
- Bluetooth
- SDDM (display manager)
- UFW (firewall)
- Power Profiles Daemon

### 7. User Configuration
Adds current user to the `docker` group for Docker usage without sudo.

### 8. Dotfiles Deployment
Clones and applies dotfiles from byakko-theme repository:
- Backs up existing dotfiles
- Clones fresh copy from GitHub
- Runs install script if present
- Manually copies configs if no install script exists

## Hardware Detection

### CPU Detection
The script detects your CPU vendor and installs the appropriate microcode:

| CPU Vendor | Package Installed |
|------------|-------------------|
| Intel | `intel-ucode` |
| AMD | `amd-ucode` |
| Unknown | Skipped with warning |

### GPU Detection
The script detects your GPU and installs appropriate drivers:

| GPU Vendor | Packages Installed |
|------------|-------------------|
| NVIDIA | `nvidia-open-dkms`, `nvidia-utils`, `lib32-nvidia-utils`, `libva-nvidia-driver` |
| AMD | `mesa`, `lib32-mesa`, `vulkan-radeon`, `lib32-vulkan-radeon`, `libva-mesa-driver`, `mesa-vdpau` |
| Intel | `mesa`, `lib32-mesa`, `vulkan-intel`, `lib32-vulkan-intel`, `intel-media-driver` |
| Unknown | `mesa`, `lib32-mesa` (generic fallback) |

## Package Lists

### Official Repository Packages (166)

#### Terminal & Shell
- `alacritty` - GPU-accelerated terminal emulator
- `kitty` - Fast, feature-rich terminal
- `ghostty` - Modern terminal emulator
- `bash-completion` - Bash auto-completion
- `starship` - Cross-shell prompt

#### System Utilities
- `base` - Minimal package set for Arch Linux
- `base-devel` - Development tools (compilers, make, etc.)
- `linux` - Linux kernel
- `linux-firmware` - Firmware files for Linux
- `linux-headers` - Headers for building kernel modules
- `efibootmgr` - EFI boot manager
- `limine` - Modern UEFI bootloader
- `btrfs-progs` - Btrfs filesystem utilities
- `snapper` - Snapshot management tool
- `intel-ucode` - Intel CPU microcode (auto-detected)

#### File Management
- `nautilus` - GNOME file manager
- `sushi` - File previewer for Nautilus
- `gnome-disk-utility` - Disk management utility
- `exfatprogs` - exFAT filesystem utilities
- `gvfs-mtp` - MTP support (Android devices)
- `gvfs-nfs` - NFS support
- `gvfs-smb` - Samba/Windows share support

#### Development Tools
- `git` - Version control system
- `github-cli` - GitHub command-line tool
- `neovim` - Modern Vim-based text editor
- `docker` - Container platform
- `docker-buildx` - Docker build extension
- `docker-compose` - Multi-container Docker applications
- `nodejs-lts-krypton` - Node.js LTS version
- `npm` - Node package manager
- `python-gobject` - Python GObject bindings
- `python-poetry-core` - Python packaging core
- `ruby` - Ruby programming language
- `rust` - Rust programming language
- `clang` - C/C++ compiler
- `llvm` - Compiler infrastructure
- `mise` - Development environment manager
- `luarocks` - Lua package manager

#### Text Editors & IDEs
- `neovim` - Hyperextensible Vim-based text editor

#### Browsers
- `firefox` - Mozilla Firefox web browser
- `chromium` - Open-source Chrome browser

#### Hyprland & Wayland
- `hyprland` - Dynamic tiling Wayland compositor
- `hyprland-guiutils` - GUI utilities for Hyprland
- `hyprlock` - Screen locker for Hyprland
- `hypridle` - Idle daemon for Hyprland
- `hyprpicker` - Color picker for Hyprland
- `hyprsunset` - Screen temperature adjuster
- `xdg-desktop-portal-hyprland` - Hyprland portal implementation
- `xdg-desktop-portal-gtk` - GTK portal implementation
- `qt5-wayland` - Qt5 Wayland support
- `qt6-wayland` - Qt6 Wayland support
- `egl-wayland` - EGL Wayland platform

#### Window Management & UI
- `waybar` - Customizable Wayland bar
- `rofi` - Application launcher
- `mako` - Notification daemon
- `swaybg` - Wallpaper tool for Wayland
- `swayosd` - OSD for brightness/volume
- `grim` - Screenshot utility for Wayland
- `slurp` - Region selector for Wayland
- `satty` - Screenshot annotation tool
- `imv` - Image viewer for Wayland
- `wl-clipboard` - Wayland clipboard utilities

#### Display & Login
- `sddm` - Display manager
- `plymouth` - Boot splash screen

#### Audio
- `pipewire` - Modern audio server
- `pipewire-alsa` - ALSA support for PipeWire
- `pipewire-jack` - JACK support for PipeWire
- `pipewire-pulse` - PulseAudio replacement
- `libpulse` - PulseAudio library
- `wireplumber` - PipeWire session manager
- `playerctl` - Media player controller
- `pamixer` - PulseAudio mixer

#### Bluetooth & Wireless
- `bluetui` - Bluetooth TUI manager
- `bolt` - Thunderbolt device manager
- `iwd` - Wireless daemon
- `wireless-regdb` - Wireless regulatory database
- `nss-mdns` - mDNS resolution

#### Fonts
- `noto-fonts` - Google Noto fonts
- `noto-fonts-cjk` - CJK (Chinese/Japanese/Korean) fonts
- `noto-fonts-emoji` - Emoji fonts
- `noto-fonts-extra` - Additional Noto fonts
- `ttf-jetbrains-mono-nerd` - JetBrains Mono Nerd Font
- `ttf-cascadia-mono-nerd` - Cascadia Mono Nerd Font
- `fontconfig` - Font configuration library
- `woff2-font-awesome` - Font Awesome icons

#### System Monitoring & Info
- `btop` - Resource monitor
- `fastfetch` - System info tool
- `inxi` - System information script
- `plocate` - Fast file locator

#### CLI Utilities
- `bat` - Cat clone with syntax highlighting
- `eza` - Modern ls replacement
- `dust` - Disk usage analyzer
- `fd` - User-friendly find alternative
- `ripgrep` - Fast grep alternative
- `fzf` - Fuzzy finder
- `zoxide` - Smarter cd command
- `tree-sitter-cli` - Parser generator tool
- `jq` - JSON processor
- `unzip` - ZIP extraction utility
- `less` - File pager
- `man-db` - Manual page database
- `tldr` - Simplified man pages
- `whois` - WHOIS client
- `inetutils` - Network utilities
- `expac` - Pacman database extraction utility
- `usage` - Usage statistics tool

#### Git Tools
- `lazygit` - Terminal UI for git
- `lazydocker` - Terminal UI for Docker

#### Printing
- `cups` - Printing system
- `cups-browsed` - CUPS printer browsing
- `cups-filters` - CUPS filters
- `cups-pdf` - PDF printer for CUPS
- `system-config-printer` - Printer configuration tool

#### Multimedia
- `mpv` - Media player
- `ffmpegthumbnailer` - Video thumbnailer
- `gst-plugin-pipewire` - PipeWire GStreamer plugin
- `imagemagick` - Image manipulation tools
- `evince` - Document viewer

#### Office & Productivity
- `libreoffice-fresh` - Office suite
- `gnome-calculator` - Calculator application
- `libqalculate` - Advanced calculator library

#### Input Methods
- `fcitx5` - Input method framework
- `fcitx5-gtk` - GTK support for fcitx5
- `fcitx5-qt` - Qt support for fcitx5

#### Theming
- `gnome-themes-extra` - Additional GNOME themes
- `gnome-keyring` - Password manager
- `kvantum-qt5` - Qt5 theme engine
- `polkit-gnome` - GNOME polkit agent

#### System Libraries
- `mariadb-libs` - MySQL/MariaDB libraries
- `postgresql-libs` - PostgreSQL libraries
- `libyaml` - YAML parser library

#### Hardware
- `brightnessctl` - Brightness control
- `power-profiles-daemon` - Power profile management
- `sof-firmware` - Sound Open Firmware

#### Security
- `ufw` - Uncomplicated Firewall

#### Misc
- `archiso` - Arch ISO creation tools
- `gum` - Glamorous shell scripts
- `xdg-terminal-exec` - Terminal launcher

### AUR Packages (26)

#### Development
- `claude-code` - Claude AI code assistant
- `cursor-bin` - AI-powered code editor
- `cursor-cli` - Cursor CLI tools
- `github-desktop-bin` - GitHub Desktop client

#### Applications
- `spotify` - Music streaming client
- `localsend` - Local file sharing
- `webapp-manager` - Web app manager
- `pinta` - Image editor
- `typora` - Markdown editor

#### System Tools
- `yay` - AUR helper
- `pacseek-bin` - Pacman package explorer
- `walker` - Application launcher
- `wayfreeze` - Screen freezer for Wayland
- `tzupdate` - Automatic timezone updater

#### Gaming
- `xivlauncher` - Final Fantasy XIV launcher

#### Media
- `gpu-screen-recorder` - GPU-accelerated screen recorder

#### Fonts & Themes
- `ttf-ia-writer` - iA Writer font
- `yaru-icon-theme` - Ubuntu Yaru icons

#### Networking
- `ufw-docker` - UFW rules for Docker

#### Hyprland Extensions
- `hyprland-preview-share-picker` - Screen sharing picker

#### Python Tools
- `python-terminaltexteffects` - Terminal text effects

#### AI/CLI Tools
- `gemini-cli` - Google Gemini CLI (from official repos)
- `impala` - TUI for Impala (from official repos)
- `wiremix` - Audio mixer (from official repos)

## Services Configured

The script enables and starts these systemd services:

| Service | Purpose |
|---------|---------|
| `docker.service` | Container runtime |
| `cups.service` | Printing system |
| `bluetooth.service` | Bluetooth support |
| `sddm.service` | Display manager (login screen) |
| `ufw.service` | Firewall |
| `power-profiles-daemon.service` | Power management |

## Dotfiles Deployment

### Process

1. **Backup**: Existing `~/byakko-theme` directory is backed up with timestamp
2. **Clone**: Fresh clone of https://github.com/DanielCoffey1/byakko-theme
3. **Installation**:
   - If `install.sh` exists: Runs the installation script
   - If `setup.sh` exists: Runs the setup script
   - Otherwise: Manually copies dotfiles from `.config/`, `.bashrc`, `.bash_profile`

### Files Deployed

The byakko-theme repository contains configurations for:
- Hyprland (window manager)
- Waybar (status bar)
- Terminal configurations
- Shell configurations
- Application themes and settings

### Backup Locations

- Dotfiles repo: `~/byakko-theme.backup.YYYYMMDD_HHMMSS`
- Config directory: `~/.config.backup.YYYYMMDD_HHMMSS`

## Post-Installation

### Required Actions

1. **Reboot** your system:
```bash
reboot
```

2. **Log out and back in** for group changes (Docker) to take effect

3. **Verify drivers** after reboot:
   - NVIDIA: `nvidia-smi`
   - Any GPU: `glxinfo | grep "OpenGL renderer"`

### Optional Configuration

#### Docker
Your user is added to the `docker` group, allowing Docker usage without sudo.

#### UFW Firewall
UFW is enabled but has default rules. Configure as needed:
```bash
sudo ufw status
sudo ufw allow [port]
```

#### Bluetooth
Enable bluetooth on startup:
```bash
sudo systemctl enable bluetooth.service
```

## Troubleshooting

### Package Conflicts

If you encounter package conflicts (e.g., `wayfreeze-git` vs `wayfreeze`):
- Answer `y` to remove the conflicting package
- Or answer `n` and manually resolve the conflict
- The script will skip already-installed packages on subsequent runs

### Driver Issues

If graphics aren't working after installation:
1. Check detected hardware: Script shows detected CPU/GPU at completion
2. Verify correct drivers installed: `pacman -Q | grep -E "(nvidia|mesa|intel-media)"`
3. Rebuild initramfs: `sudo mkinitcpio -P`
4. Check kernel logs: `dmesg | grep -E "(nvidia|amdgpu|i915)"`

### AUR Build Failures

If AUR packages fail to build:
1. Check you have enough disk space
2. Ensure `base-devel` is installed
3. Manually build the failing package: `yay -S [package-name]`
4. Re-run the script

### Dotfiles Issues

If dotfiles don't apply correctly:
1. Check the byakko-theme repository was cloned: `ls ~/byakko-theme`
2. Restore backup if needed: `cp -r ~/.config.backup.* ~/.config`
3. Manually run: `cd ~/byakko-theme && ./install.sh`

### Service Failures

If services fail to start:
```bash
sudo systemctl status [service-name]
sudo journalctl -u [service-name]
```

## Hardware Compatibility

### Tested On
- Intel CPUs with NVIDIA GPUs
- Intel integrated graphics

### Should Work On
- AMD CPUs with AMD GPUs
- AMD CPUs with NVIDIA GPUs
- Intel CPUs with AMD GPUs
- Any combination of Intel/AMD CPU and NVIDIA/AMD/Intel GPU

### Known Limitations
- Script assumes x86_64 architecture
- Some AUR packages may not be available for ARM
- NVIDIA drivers require compatible GPU (check NVIDIA website)

## Credits

- Dotfiles: [byakko-theme](https://github.com/DanielCoffey1/byakko-theme)
- Hyprland configuration based on my personal setup
- Package selection refined through daily use

## License

This script is provided as-is for personal use. Modify as needed for your own setup.

## Contributing

This is my personal system configuration, but feel free to fork and adapt for your own use!
