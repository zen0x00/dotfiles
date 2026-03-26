#!/bin/bash

install_core_packages() {

    local packages=(
        # Hyprland compositor & core components
        hyprland
        xdg-desktop-portal-hyprland
        xdg-terminal-exec
        hyprpolkitagent
        hypridle
        hyprsunset
        hyprshot

        # Display manager
        ly

        # Shell
        quickshell

        # Network
        networkmanager
        dnsmasq

        # Fonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
        ttf-gohu-nerd
        ttf-ibm-plex
        ttf-jetbrains-mono-nerd
        ttf-roboto
        ttf-twemoji

        # Storage & file system
        ntfs-3g
        gvfs
        gvfs-mtp

        # Authentication & secrets
        gnome-keyring
        libsecret

        # Audio (PipeWire)
        pipewire
        pipewire-alsa
        pipewire-jack
        pipewire-pulse
        wireplumber

        # Graphics
        vulkan-icd-loader
        lib32-vulkan-icd-loader

        # Bluetooth
        bluez
        bluez-utils

        # Clipboard
        cliphist
        wl-clipboard

        # Brightness & input control
        brightnessctl

        # Notifications
        libnotify

        # Qt theming (Wayland)
        kvantum
        qt5-base
        qt5-wayland
        qt5ct
        qt6-5compat
        qt6-base
        qt6-declarative
        qt6-multimedia
        qt6-quicktimeline
        qt6-shadertools
        qt6-svg
        qt6-wayland
        qt6ct

        # GTK settings
        nwg-look

        # Icons
        yaru-icon-theme

        # Dotfiles management
        stow

        # Basic utilities
        curl
        jq
        wget
    )

    local to_install=()

    for pkg in "${packages[@]}"; do
        if pacman -Qi "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed — skipping."
        else
            to_install+=("$pkg")
        fi
    done

    if (( ${#to_install[@]} > 0 )); then
        yay -S --noconfirm "${to_install[@]}"
    fi
}
