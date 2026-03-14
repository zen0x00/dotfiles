#!/bin/bash

run_stow() {
    local CONFIG_DIR="$HOME/.config"
    mkdir -p "$CONFIG_DIR"

    local folders=(btop fastfetch fish hypr kitty nvim swaync swayosd themes uwsm walker waybar wlogout yazi zen0x)

    for folder in "${folders[@]}"; do
        local target="$CONFIG_DIR/$folder"
        mkdir -p "$target"

        info "📦 Stowing $folder..."

        stow --target="$target" "$folder"

        ok "$folder stowed successfully."
    done
}
