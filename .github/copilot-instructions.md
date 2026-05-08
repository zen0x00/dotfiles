# Copilot Instructions

## Build, test, and validation commands

This repository does not have a package manifest, test suite, or lint target. There is no theme generation step — colors are static files committed directly to the repo.

Useful validation entrypoints:
- `bash -n <script>` — syntax-check any shell script in `bin/`
- `stow --simulate --dir=. --target=$HOME/.config/<pkg> --stow <pkg>` — dry-run stow for any package
- `hyprctl reload` — apply Hyprland config changes live
- `astal -i zen0x reload-css` — apply AGS CSS changes live

There is no single-test command because there is no test runner in this repo.

## High-level architecture

The repository is a dotfiles layout organized around stowable app directories. Each app directory contains files that land inside `~/.config/<app>/` via stow.

**Static theme:** Colors are hardcoded directly in each app's config files — no generation step, no templates, no theme variants. To change a color, edit the relevant file directly:

| App | Color file |
|-----|-----------|
| Hyprland | `hypr/colors.conf` |
| Hyprlock | `hypr/hyprlock.conf` |
| AGS | `ags/style/colors.css` |
| Kitty | `kitty/colors.conf` |
| Nvim | `nvim/lua/zen0x/colors.lua` |
| FastFetch | `fastfetch/config.jsonc` |
| OpenCode | `opencode/themes/zen0x.json` |

**Stow packages** deployed to `~/.config/<pkg>/`: `fastfetch`, `hypr`, `kitty`, `opencode`, `rofi`, `swayosd`, `swaync`, `waybar`. `bin/` is stowed to `/usr/bin/`.

**Nvim** is not a stow package — `nvim/lua/zen0x/colors.lua` is symlinked explicitly via `modules/stow.sh`.

**AGS** (`ags/`) is deployed with individual symlinks rather than a full stow package. `~/.config/ags/style/` is a direct symlink to `dotfiles/ags/style/`.

Hyprland is split into numbered modules under `hypr/modules/`. `hypr/hyprland.conf` sources them in order. Edit the appropriate numbered module instead of the top-level file.

## Key conventions

- Colors are static. Do not add a generation step or templating system. Edit color files directly.
- Keep Hyprland module filenames numbered (`00-`, `01-`, `10-`, etc.) — the prefix determines source order.
- AGS CSS variables are defined in `ags/style/colors.css` and consumed by `bar.css`, `launcher.css`, `notifications.css`, `osd.css`.
- The `bin/` scripts that remain (`zen0x-powermenu`, `zen0x-toggle-*`) are unrelated to theming — they control system state.
