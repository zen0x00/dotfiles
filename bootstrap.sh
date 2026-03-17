#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load utilities
source "$BASE_DIR/utils/logging.sh"
source "$BASE_DIR/utils/checks.sh"

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
info "Select machine type:"
echo "1) Desktop"
echo "2) Laptop"
echo

read -rp "Enter choice (1/2): " MACHINE
echo

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
echo
info "Select installation mode:"
echo "1) Minimal (Hyprland desktop core only)"
echo "2) Full    (Minimal + all apps, tools, and dev packages)"
echo

read -rp "Enter choice (1/2): " MODE
echo

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

# Load modules
source "$BASE_DIR/modules/git.sh"
source "$BASE_DIR/modules/packages-core.sh"
source "$BASE_DIR/modules/packages-extra.sh"
source "$BASE_DIR/modules/stow.sh"
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
