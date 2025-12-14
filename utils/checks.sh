#!/bin/bash

# Prevent running as root
check_not_root() {
    if [[ "$EUID" -eq 0 ]]; then
        err "Do NOT run this script as root!"
        exit 1
    fi
}

# Check internet connectivity
check_internet() {
    info "Checking internet connection..."
    if ! ping -c 1 archlinux.org >/dev/null 2>&1; then
        err "No internet connection detected!"
        exit 1
    fi
}

# Ensure YAY exists or install it
check_yay() {
    if ! command -v yay >/dev/null 2>&1; then
        warn "yay not found — installing..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
        ok "yay installed!"
    else
        ok "yay already installed."
    fi
}
