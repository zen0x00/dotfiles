#!/bin/bash

reboot_prompt() {

    echo
    info "Choose what to do next:"
    echo "1) Reboot normally"
    echo "2) Reboot into BIOS (Firmware Setup)"
    echo "3) Exit"
    echo

    read -rp "Enter choice (1/2/3): " R

    case "$R" in
        1)
            ok "Rebooting..."
            sudo reboot
            ;;
        2)
            info "Attempting UEFI firmware reboot..."
            if systemctl reboot --firmware-setup 2>/dev/null; then
                exit 0
            else
                warn "Firmware reboot failed. Falling back to efibootmgr..."
                sudo efibootmgr -n 0
                sudo reboot
            fi
            ;;
        3)
            ok "Done. Exiting."
            exit 0
            ;;
        *)
            err "Invalid choice."
            ;;
    esac
}
