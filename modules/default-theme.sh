apply_default_theme() {
    local THEMES="$HOME/.config/themes"
    local CURRENT="$THEMES/current"
    local DEFAULT_THEME="Abyssal"

    if [[ -d "$THEMES/$DEFAULT_THEME" ]]; then
        info "Applying default theme: $DEFAULT_THEME"

        ln -sfn "$THEMES/$DEFAULT_THEME" "$CURRENT"

        zen0x-apply-generated-theme
        zen0x-theme-gtk
        zen0x-theme-set-vscode
        zen0x-theme-wallpaper "$DEFAULT_THEME"
        zen0x-theme-reload

        ok "Default theme applied."
    else
        warn "Default theme '$DEFAULT_THEME' not found. Skipping theme setup."
    fi
}
