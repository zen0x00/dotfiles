#!/bin/bash

setup_zsh() {
    info "Setting up Zsh environment..."

    # ----------------------------------------------------------
    # 1. Remove existing ~/.zshrc (only if it's not a symlink)
    # ----------------------------------------------------------
    if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
        warn "~/.zshrc exists — removing it before stowing dotfiles."
        rm "$HOME/.zshrc"
    fi

    # ----------------------------------------------------------
    # 4. Stow zsh dotfiles (to $HOME)
    # ----------------------------------------------------------
    if [[ -d "$HOME/dotfiles/zsh" ]]; then
        info "Stowing Zsh dotfiles..."
        stow --target="$HOME" zsh
        ok "Zsh dotfiles linked."
    else
        warn "arch/zsh folder not found — skipping stow."
    fi

    ok "Zsh setup complete."
}
