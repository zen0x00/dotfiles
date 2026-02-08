#!/bin/bash

run_unstow() {
    local CONFIG_DIR="$HOME/.config"
    local folders=(hypr waybar kitty fastfetch rofi gtk-3.0 gtk-4.0 swaync swayosd wlogout)

    for folder in "${folders[@]}"; do
        local target="$CONFIG_DIR/$folder"
        stow --delete --target="$target" "$folder"
    done
}

run_unstow
