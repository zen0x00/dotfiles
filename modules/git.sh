#!/bin/bash

configure_git_if_needed() {

    local existing_name
    local existing_email

    existing_name=$(git config --global user.name || true)
    existing_email=$(git config --global user.email || true)

    if [[ -n "$existing_name" && -n "$existing_email" ]]; then
        ok "Git already configured as: $existing_name <$existing_email>"
        return
    fi

    info "Git is not configured. Let's set it up."

    while [[ -z "${GIT_NAME:-}" ]]; do
        read -rp "Enter your Git user.name: " GIT_NAME
    done

    while [[ -z "${GIT_EMAIL:-}" ]]; do
        read -rp "Enter your Git user.email: " GIT_EMAIL
    done

    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global init.defaultBranch main

    ok "Git configured as $GIT_NAME <$GIT_EMAIL>"
}
