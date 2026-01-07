#!/usr/bin/env bash

set -e

echo "=========================================="
echo "Arch Linux System Replication Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Hardware detection functions
detect_cpu() {
    if lscpu | grep -qi "GenuineIntel"; then
        echo "intel"
    elif lscpu | grep -qi "AuthenticAMD"; then
        echo "amd"
    else
        echo "unknown"
    fi
}

detect_gpu() {
    if lspci | grep -i vga | grep -qi nvidia; then
        echo "nvidia"
    elif lspci | grep -i vga | grep -qi amd; then
        echo "amd"
    elif lspci | grep -i vga | grep -qi intel; then
        echo "intel"
    else
        echo "unknown"
    fi
}

# Detect hardware
print_status "Detecting hardware..."
CPU_VENDOR=$(detect_cpu)
GPU_VENDOR=$(detect_gpu)

print_status "Detected CPU: $CPU_VENDOR"
print_status "Detected GPU: $GPU_VENDOR"

# Update system first
print_status "Updating system..."
sudo pacman -Syu --noconfirm

# Install base-devel if not already installed (needed for AUR)
print_status "Installing base-devel..."
sudo pacman -S --needed --noconfirm base-devel git

# Install yay (AUR helper) if not already installed
if ! command -v yay &> /dev/null; then
    print_status "Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
else
    print_status "yay is already installed"
fi

# Official repository packages
print_status "Installing official repository packages..."
OFFICIAL_PACKAGES=(
    alacritty
    archiso
    base
    base-devel
    bash-completion
    bat
    bluetui
    bolt
    brightnessctl
    btop
    btrfs-progs
    chromium
    clang
    cups
    cups-browsed
    cups-filters
    cups-pdf
    docker
    docker-buildx
    docker-compose
    dust
    efibootmgr
    egl-wayland
    evince
    exfatprogs
    expac
    eza
    fastfetch
    fcitx5
    fcitx5-gtk
    fcitx5-qt
    fd
    ffmpegthumbnailer
    firefox
    fontconfig
    fzf
    gemini-cli
    ghostty
    git
    github-cli
    gnome-calculator
    gnome-disk-utility
    gnome-keyring
    gnome-themes-extra
    grim
    gst-plugin-pipewire
    gum
    gvfs-mtp
    gvfs-nfs
    gvfs-smb
    hypridle
    hyprland
    hyprland-guiutils
    hyprlock
    hyprpicker
    hyprsunset
    imagemagick
    impala
    imv
    inetutils
    inxi
    iwd
    jq
    kitty
    kvantum-qt5
    lazydocker
    lazygit
    less
    libpulse
    libqalculate
    libreoffice-fresh
    libyaml
    limine
    linux
    linux-firmware
    linux-headers
    llvm
    luarocks
    mako
    man-db
    mariadb-libs
    mise
    mpv
    nautilus
    neovim
    nodejs-lts-krypton
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    npm
    nss-mdns
    pamixer
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    playerctl
    plocate
    plymouth
    polkit-gnome
    postgresql-libs
    power-profiles-daemon
    python-gobject
    python-poetry-core
    qt5-wayland
    qt6-wayland
    ripgrep
    rofi
    ruby
    rust
    satty
    sddm
    slurp
    snapper
    sof-firmware
    starship
    sushi
    swaybg
    swayosd
    system-config-printer
    tldr
    tree-sitter-cli
    ttf-cascadia-mono-nerd
    ttf-jetbrains-mono-nerd
    ufw
    unzip
    usage
    uwsm
    waybar
    whois
    wireless-regdb
    wiremix
    wireplumber
    wl-clipboard
    woff2-font-awesome
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
)

sudo pacman -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"

# Install CPU microcode
print_status "Installing CPU microcode..."
if [ "$CPU_VENDOR" == "intel" ]; then
    print_status "Installing Intel microcode..."
    sudo pacman -S --needed --noconfirm intel-ucode
elif [ "$CPU_VENDOR" == "amd" ]; then
    print_status "Installing AMD microcode..."
    sudo pacman -S --needed --noconfirm amd-ucode
else
    print_warning "Unknown CPU vendor, skipping microcode installation"
fi

# Install GPU drivers
print_status "Installing GPU drivers..."
if [ "$GPU_VENDOR" == "nvidia" ]; then
    print_status "Installing NVIDIA drivers..."
    sudo pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver
elif [ "$GPU_VENDOR" == "amd" ]; then
    print_status "Installing AMD drivers..."
    sudo pacman -S --needed --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver mesa-vdpau
elif [ "$GPU_VENDOR" == "intel" ]; then
    print_status "Installing Intel drivers..."
    sudo pacman -S --needed --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver
else
    print_warning "Unknown GPU vendor, skipping GPU driver installation"
    print_status "Installing generic Mesa drivers..."
    sudo pacman -S --needed --noconfirm mesa lib32-mesa
fi

# AUR packages
print_status "Installing AUR packages..."
AUR_PACKAGES=(
    claude-code
    cursor-bin
    cursor-cli
    github-desktop-bin
    gpu-screen-recorder
    hyprland-preview-share-picker
    localsend
    pacseek-bin
    pinta
    python-terminaltexteffects
    spotify
    ttf-ia-writer
    typora
    tzupdate
    ufw-docker
    walker
    wayfreeze
    webapp-manager
    xdg-terminal-exec
    xivlauncher
    yaru-icon-theme
)

yay -S --needed "${AUR_PACKAGES[@]}"

# Enable services
print_status "Enabling system services..."
sudo systemctl enable --now docker.service
sudo systemctl enable --now cups.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now sddm.service
sudo systemctl enable --now ufw.service
sudo systemctl enable --now power-profiles-daemon.service

# Add user to docker group
print_status "Adding user to docker group..."
sudo usermod -aG docker $USER

# Clone and apply dotfiles
print_status "Cloning and applying dotfiles from byakko-theme..."
DOTFILES_DIR="$HOME/byakko-theme"

if [ -d "$DOTFILES_DIR" ]; then
    print_warning "Dotfiles directory already exists. Backing up to ${DOTFILES_DIR}.backup"
    mv "$DOTFILES_DIR" "${DOTFILES_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
fi

git clone https://github.com/DanielCoffey1/byakko-theme.git "$DOTFILES_DIR"

cd "$DOTFILES_DIR"

# Check if there's an install script in the repo
if [ -f "install.sh" ]; then
    print_status "Running dotfiles install script..."
    chmod +x install.sh
    ./install.sh
elif [ -f "setup.sh" ]; then
    print_status "Running dotfiles setup script..."
    chmod +x setup.sh
    ./setup.sh
else
    # Manual dotfile deployment
    print_status "Manually deploying dotfiles..."

    # Backup existing config
    if [ -d "$HOME/.config" ]; then
        print_warning "Backing up existing .config to ~/.config.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.config" "$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Copy dotfiles (adjust these paths based on your repo structure)
    if [ -d ".config" ]; then
        cp -r .config/* "$HOME/.config/"
    fi

    if [ -f ".bashrc" ]; then
        cp .bashrc "$HOME/.bashrc"
    fi

    if [ -f ".bash_profile" ]; then
        cp .bash_profile "$HOME/.bash_profile"
    fi

    # Add more dotfile copies as needed
fi

cd ~

print_status "=========================================="
print_status "Installation complete!"
print_status "=========================================="
echo ""
print_status "Hardware detected and configured:"
print_status "  CPU: $CPU_VENDOR"
print_status "  GPU: $GPU_VENDOR"
echo ""
print_warning "Please reboot your system to apply all changes"
print_warning "You may need to log out and back in for group changes to take effect"
print_warning "After reboot, verify drivers are working:"
if [ "$GPU_VENDOR" == "nvidia" ]; then
    print_warning "  - Run 'nvidia-smi' to verify NVIDIA driver"
fi
print_warning "  - Run 'glxinfo | grep \"OpenGL renderer\"' to verify GPU"
echo ""
