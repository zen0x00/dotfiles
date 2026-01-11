#!/bin/bash

install_core_packages() {

    local packages=(
        # --- Original core packages ---
        ntfs-3g gnome-keyring noto-fonts-cjk noto-fonts noto-fonts-extra
        noto-fonts-emoji libsecret seahorse efibootmgr os-prober vulkan-icd-loader lib32-vulkan-icd-loader
        bluez bluez-utils power-profiles-daemon

        # --- Added System Utilities ---
        brightnessctl pavucontrol playerctl
        wl-clipboard cliphist
        networkmanager network-manager-applet
        gvfs gvfs-mtp

        # --- Added Appearance / QT / Theming ---
        qt5-base qt6-base
        qt5-wayland qt6-wayland
        qt5ct lxappearance sassc

        # --- Networking / Connectivity ---
        openssh rsync wget curl ufw

        # --- Archive / Compression Tools ---
        zip unzip p7zip gzip tar

        # --- System Cleaning Tools ---
        ncdu bleachbit duf dust

        # --- Workflow Tools ---
        bat ripgrep fd btop
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
