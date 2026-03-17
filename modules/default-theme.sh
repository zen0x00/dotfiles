apply_default_theme() {
    local DOTFILES_DIR
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    local THEMES="$HOME/.config/themes/colorschemes"
    local WAYBAR_THEMES="$HOME/.config/themes/waybar"
    local CURRENT="$HOME/.config/themes/current"
    local WAYBAR_DIR="$HOME/.config/waybar"
    local DEFAULT_THEME="Abyssal"
    local DEFAULT_WAYBAR_THEME="Default"

    # -----------------------------------------------
    # 1. Ensure color scheme directory and theme exist
    # -----------------------------------------------
    mkdir -p "$THEMES"

    if [[ ! -d "$THEMES/$DEFAULT_THEME" ]]; then
        if [[ -d "$DOTFILES_DIR/themes/colorschemes/$DEFAULT_THEME" ]]; then
            ln -sfn "$DOTFILES_DIR/themes/colorschemes/$DEFAULT_THEME" "$THEMES/$DEFAULT_THEME"
            info "Linked $DEFAULT_THEME from repo to $THEMES"
        fi
    fi

    # -----------------------------------------------
    # 2. Ensure waybar theme directory and theme exist
    # -----------------------------------------------
    mkdir -p "$WAYBAR_THEMES"

    if [[ ! -d "$WAYBAR_THEMES/$DEFAULT_WAYBAR_THEME" ]]; then
        if [[ -d "$DOTFILES_DIR/themes/waybar/$DEFAULT_WAYBAR_THEME" ]]; then
            ln -sfn "$DOTFILES_DIR/themes/waybar/$DEFAULT_WAYBAR_THEME" "$WAYBAR_THEMES/$DEFAULT_WAYBAR_THEME"
            info "Linked waybar theme $DEFAULT_WAYBAR_THEME from repo to $WAYBAR_THEMES"
        fi
    fi

    # -----------------------------------------------
    # 3. Apply default color scheme
    # -----------------------------------------------
    if [[ -d "$THEMES/$DEFAULT_THEME" ]]; then
        info "Applying default theme: $DEFAULT_THEME"

        ln -sfn "$THEMES/$DEFAULT_THEME" "$CURRENT"

        zen0x-theme-generate "$DEFAULT_THEME"
        zen0x-apply-generated-theme
        zen0x-theme-gtk
        zen0x-theme-set-vscode
        zen0x-theme-wallpaper "$DEFAULT_THEME"

        ok "Default color scheme applied."
    else
        warn "Default theme '$DEFAULT_THEME' not found. Skipping theme setup."
    fi

    # -----------------------------------------------
    # 4. Apply default waybar theme
    # -----------------------------------------------
    if [[ -d "$WAYBAR_THEMES/$DEFAULT_WAYBAR_THEME" ]]; then
        info "Applying default waybar theme: $DEFAULT_WAYBAR_THEME"

        mkdir -p "$WAYBAR_DIR"
        ln -sfn "$WAYBAR_THEMES/$DEFAULT_WAYBAR_THEME/config.jsonc" "$WAYBAR_DIR/config.jsonc"
        ln -sfn "$WAYBAR_THEMES/$DEFAULT_WAYBAR_THEME/style.css" "$WAYBAR_DIR/style.css"

        ok "Default waybar theme applied."
    else
        warn "Default waybar theme '$DEFAULT_WAYBAR_THEME' not found. Skipping waybar theme setup."
    fi

    # -----------------------------------------------
    # 5. Reload UI
    # -----------------------------------------------
    zen0x-theme-reload
}
