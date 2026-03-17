#!/bin/bash

install_extra_packages() {
    local packages=(
        # System tools & utilities
        bat
        btop
        edk2-ovmf
        fd
        gzip
        openbsd-netcat
        openssh
        os-prober
        p7zip
        pavucontrol
        qemu-full
        ripgrep
        rsync
        sassc
        tar
        ufw
        unzip
        vde2
        virt-manager
        virt-viewer
        zip

        # Virtualisation networking
        bridge-utils

        # Performance & scheduling
        cpupower
        irqbalance
        preload
        scx-scheds
        tuned
        tuned-ppd
        zram-generator

        # Terminal & shell
        fish
        kitty
        starship
        zoxide

        # CLI tools
        ani-cli
        awww-git
        bc
        fastfetch
        fzf
        imagemagick
        impala
        lazygit
        yad
        yazi

        # Bluetooth TUI
        bluetui

        # Audio & video
        ffmpeg
        obs-pipewire-audio-capture
        obs-studio
        obs-vkcapture
        spicetify-cli
        spotify
        wiremix

        # Gaming
        gamemode
        heroic-games-launcher
        lib32-gamemode
        mangohud
        mangojuice
        steam
        wine
        winetricks

        # GPU & hardware
        gpu-screen-recorder
        openrgb

        # Input method
        fcitx5

        # GTK / theming
        abyssal-gtk-theme
        gtk-engine-murrine
        sunset-cursors-git

        # File managers
        nautilus
        thunar

        # Apps
        brave-bin
        localsend
        vesktop

        # Screen capture
        satty

        # Neovim
        neovim

        # Developer tools
        clang
        cmake
        dotnet-sdk
        gdb
        gcc
        git-lfs
        github-cli
        github-copilot-cli
        go
        lldb
        make
        mono
        ninja
        ruby
        unityhub
        visual-studio-code-bin
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
