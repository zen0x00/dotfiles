#!/bin/bash

run_stow() {
    local CONFIG_DIR="$HOME/.config"
    mkdir -p "$CONFIG_DIR"

    local folders=(alacritty btop fastfetch hypr nvim rofi swaync swayosd themes waybar wlogout zen0x)

    for folder in "${folders[@]}"; do
        local target="$CONFIG_DIR/$folder"
        mkdir -p "$target"

        info "📦 Stowing $folder..."

        stow --target="$target" "$folder"

        ok "$folder stowed successfully."
    done
    mkdir -p "$HOME/.config/oh-my-posh"
    mkdir -p "$HOME/Pictures"
    stow --target="$HOME/Pictures" Pictures
    ok "starship stowed successfully."

}
