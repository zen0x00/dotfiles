#!/bin/bash

install_aur_packages() {
    local packages=(
        abyssal-gtk-theme
        alacritty
        ani-cli
        awww-git
        bc
        bluetui
        cpupower
        ffmpeg
        fastfetch
        fzf
        gamemode
        github-copilot-cli
        gtk-engine-murrine
        heroic-games-launcher
        hyprland
        hyprpolkitagent
        hyprshot
        hyprsunset
        impala
        imagemagick
        irqbalance
        jq
        lazygit
        lib32-gamemode
        localsend
        ly
        mangohud
        mangojuice
        nautilus
        neovim
        notify-send
        noto-fonts
        nwg-look
        obs-pipewire-audio-capture
        obs-studio
        obs-vkcapture
	      oh-my-posh
        openrgb
        preload
        rofi-wayland
        satty
        scx-scheds
        spicetify-cli
        spotify
        starship
        steam
        stow
        sunset-cursors-git
        swaync
        swayosd
        tlauncher-installer
        tor-browser-bin
        ttf-gohu-nerd
        ttf-ibm-plex
        ttf-jetbrains-mono-nerd
        ttf-roboto
        ttf-twemoji
        tuned
        tuned-ppd
        vesktop
        waybar
        wiremix
        wlogout
        xdg-desktop-portal-hyprland
        yad
        yaru-colors-icon-theme
        yaru-icon-theme
        zram-generator
        zen-browser-bin
        zoxide
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
