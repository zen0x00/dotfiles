apply_default_theme() {
    local THEMES="$HOME/.config/themes"
    local WAYBAR_THEMES="$HOME/.config/themes-waybar"
    local CURRENT="$THEMES/current"
    local DEFAULT_THEME="Abyssal"
    local DEFAULT_WAYBAR_THEME="Default"

    if [[ -d "$THEMES/$DEFAULT_THEME" ]]; then
        info "Applying default theme: $DEFAULT_THEME"
        info "Applying default waybar theme: $DEFAULT_WAYBAR_THEME"

        ln -sfn "$THEMES/$DEFAULT_THEME" "$CURRENT"

        zen0x-apply-generated-theme
        zen0x-theme-gtk
        zen0x-theme-set-vscode
        zen0x-theme-wallpaper "$DEFAULT_THEME"
        zen0x-theme-reload

        ok "Default theme applied."
    else
        warn "Default theme '$DEFAULT_THEME' not found. Skipping theme setup."
        warn "Default waybar theme '$DEFAULT_WAYBAR_THEME' not found. Skipping waybar theme setup."
    fi
}
