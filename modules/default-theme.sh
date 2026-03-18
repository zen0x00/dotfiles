apply_default_theme() {
    local DOTFILES_DIR
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    local THEMES="$HOME/.config/themes/colorschemes"
    local CURRENT="$HOME/.config/themes/current"
    local DEFAULT_THEME="Abyssal"

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
    # 2. Apply default color scheme
    # -----------------------------------------------
    if [[ -d "$THEMES/$DEFAULT_THEME" ]]; then
        info "Applying default theme: $DEFAULT_THEME"

        ln -sfn "$THEMES/$DEFAULT_THEME" "$CURRENT"

        zen0x-theme-generate "$DEFAULT_THEME"
        zen0x-apply-generated-theme
        zen0x-theme-gtk
        zen0x-theme-set-vscode
        zen0x-theme-nvim
        zen0x-theme-wallpaper "$DEFAULT_THEME"

        ok "Default color scheme applied."
    else
        warn "Default theme '$DEFAULT_THEME' not found. Skipping theme setup."
    fi

    # -----------------------------------------------
    # 3. Reload UI
    # -----------------------------------------------
    zen0x-theme-reload
}
