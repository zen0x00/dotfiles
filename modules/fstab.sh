#!/bin/bash

update_fstab() {
    local UUID="2D5D808922F7E507"
    local USERNAME="$(id -un)"
    local HOME_DIR="/home/$USERNAME"
    local MOUNT_POINT="$HOME_DIR/HDD"

    local ENTRY="UUID=$UUID  $MOUNT_POINT  ntfs-3g  defaults,uid=1000,gid=1000,umask=022  0  0"

    info "Preparing HDD mount point at $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
    sudo chown "$USERNAME:$USERNAME" "$MOUNT_POINT"

    if ! grep -q "^UUID=$UUID" /etc/fstab; then
        info "Adding NTFS HDD entry to /etc/fstab..."
        echo -e "\n# HDD ($UUID)\n$ENTRY" | sudo tee -a /etc/fstab >/dev/null
        ok "fstab entry added."
    else
        info "fstab entry already exists — skipping."
    fi

    sudo systemctl daemon-reload
    sudo mount -a && ok "fstab validated and HDD mounted."
}

