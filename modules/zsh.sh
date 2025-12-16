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
    # 2. Install Oh My Zsh if missing
    # ----------------------------------------------------------
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        ok "Oh My Zsh installed."
    else
        ok "Oh My Zsh is already installed — skipping."
    fi

    # ----------------------------------------------------------
    # 3. Install Powerlevel10k theme
    # ----------------------------------------------------------
    local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    if [[ ! -d "$P10K_DIR" ]]; then
        info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
        ok "Powerlevel10k installed."
    else
        ok "Powerlevel10k already installed — skipping."
    fi

    # ----------------------------------------------------------
    # 4. Stow zsh dotfiles (to $HOME)
    # ----------------------------------------------------------
    if [[ -d "$HOME/dotfiles/zsh" ]]; then
        info "Stowing Zsh dotfiles..."
        stow --target="$HOME" zsh
        ok "Zsh dotfiles linked."
    else
        warn "dotfiles/zsh folder not found — skipping stow."
    fi

    ok "Zsh setup complete."
}
