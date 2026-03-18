#!/bin/bash

run_stow() {
    local CONFIG_DIR="$HOME/.config"
    mkdir -p "$CONFIG_DIR"

    local folders=(btop fastfetch fish hypr kitty nvim quickshell themes walls yazi zen0x)

    for folder in "${folders[@]}"; do
        local target="$CONFIG_DIR/$folder"
        mkdir -p "$target"

        info "Stowing $folder..."

        stow --dir="$BASE_DIR" --target="$target" "$folder"

        ok "$folder stowed successfully."
    done
}
