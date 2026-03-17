#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load utilities
source "$BASE_DIR/utils/logging.sh"
source "$BASE_DIR/utils/checks.sh"

# ------------------------------
# INTERACTIVE HELPERS
# ------------------------------
ask_choice() {
    local prompt="$1"
    local default="$2"
    shift 2
    local options=("$@")
    local input

    while true; do
        echo >&2
        info "$prompt" >&2
        for option in "${options[@]}"; do
            echo "$option" >&2
        done
        read -rp "Enter choice [default: $default]: " input >&2
        input="${input:-$default}"

        for option in "${options[@]}"; do
            local key="${option%%)*}"
            if [[ "$input" == "$key" ]]; then
                echo "$input"
                return 0
            fi
        done

        warn "Invalid choice: $input" >&2
    done
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local input

    while true; do
        if [[ "$default" == "y" ]]; then
            read -rp "$prompt [Y/n]: " input
        else
            read -rp "$prompt [y/N]: " input
        fi

        input="${input:-$default}"
        case "${input,,}" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) warn "Please answer yes or no." ;;
        esac
    done
}

confirm_or_exit() {
    if ! ask_yes_no "Continue with these settings?" "y"; then
        warn "Bootstrap cancelled by user."
        exit 0
    fi
}

info "Welcome to the Rex OS Bootstrap Installer"

# Ensure not root
check_not_root

# Ensure internet
check_internet

# Ensure yay exists (install if needed)
check_yay

# -----------------------------------------------
# MACHINE TYPE SELECTION
# -----------------------------------------------
MACHINE="$(ask_choice "Select machine type:" "1" "1) Desktop" "2) Laptop")"

case "$MACHINE" in
    1)
        ok "Desktop selected."
        MACHINE_TYPE="desktop"
        ;;
    2)
        ok "Laptop selected."
        MACHINE_TYPE="laptop"
        ;;
    *)
        err "Invalid choice."
        exit 1
        ;;
esac

# Mode selection menu
MODE="$(ask_choice "Select installation mode:" "1" "1) Minimal (Hyprland desktop core only)" "2) Full    (Minimal + all apps, tools, and dev packages)")"

case "$MODE" in
    1)
        ok "Minimal mode selected."
        INSTALL_MODE="minimal"
        ;;
    2)
        ok "Full mode selected."
        INSTALL_MODE="full"
        ;;
    *)
        err "Invalid choice."
        exit 1
        ;;
esac

    echo
    info "Configuration summary:"
    echo "- Machine type      : $MACHINE_TYPE"
    echo "- Installation mode : $INSTALL_MODE"
    confirm_or_exit

# Load modules
source "$BASE_DIR/modules/git.sh"
source "$BASE_DIR/modules/packages-core.sh"
source "$BASE_DIR/modules/packages-extra.sh"
source "$BASE_DIR/modules/stow.sh"
source "$BASE_DIR/modules/zsh.sh"
source "$BASE_DIR/modules/default-theme.sh"
source "$BASE_DIR/modules/monitors.sh"
source "$BASE_DIR/modules/bin.sh"
source "$BASE_DIR/modules/ascii.sh"
source "$BASE_DIR/modules/reboot.sh"

# -----------------------------------------------
# GIT CONFIG
# -----------------------------------------------
info "Checking Git configuration…"
configure_git_if_needed

if ask_yes_no "Proceed to package installation?" "y"; then
    ok "Starting package installation."
else
    warn "Bootstrap cancelled before package installation."
    exit 0
fi

# -----------------------------------------------
# INSTALL PACKAGES
# -----------------------------------------------

info "Installing core packages..."
install_core_packages

if [[ "$INSTALL_MODE" == "full" ]]; then
    info "Installing extra packages..."
    install_extra_packages
fi

ok "Package installation done!"

if ask_yes_no "Continue with dotfiles and desktop setup?" "y"; then
    ok "Proceeding with setup steps."
else
    warn "Bootstrap finished after package installation by request."
    exit 0
fi

# -----------------------------------------------
# LOCAL BIN
# -----------------------------------------------
info "Linking dotfiles executables..."
install_local_bin

# -----------------------------------------------
# DOTFILES (STOW)
# -----------------------------------------------
info "Applying dotfiles using stow..."
run_stow

# -----------------------------------------------
# ZSH SETUP
# -----------------------------------------------
if declare -F setup_zsh >/dev/null 2>&1; then
    info "Applying Zsh setup..."
    setup_zsh
fi

# -----------------------------------------------
# HYPRLAND MONITOR CONFIG
# -----------------------------------------------
info "Generating Hyprland monitor configuration..."
generate_monitors_conf

# -----------------------------------------------
# ASCII ART FINISH
# -----------------------------------------------
print_rex_os_banner

# -----------------------------------------------
# APPLY DEFAULT THEME
# -----------------------------------------------
info "Setting default theme..."
apply_default_theme

# -----------------------------------------------
# REBOOT MENU
# -----------------------------------------------
reboot_prompt
