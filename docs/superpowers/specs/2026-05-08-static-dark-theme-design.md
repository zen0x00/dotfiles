# Static Dark Theme Refactor

**Date:** 2026-05-08  
**Status:** Approved

## Goal

Remove the zen0x theme engine (Python generator, templates, multiple theme variants) and replace it with a single static dark theme hardcoded directly into each app's config files. Theme is designed to be neutral and work with any wallpaper.

## Color Palette

```
bg         = #0f1115     base background
bg-alt     = #151821     surface / panel
surface    = #1a1f29     elevated panels
surface-2  = #212734     further elevated

fg         = #e6e9ef     primary text
fg-muted   = #aab1bf     muted / subtle text
subtle     = #4a5568     between muted and border

primary    = #7aa2f7     accent — borders, links, focus
secondary  = #9ece6a     success, diff-added
accent     = #bb9af7     purple — highlight, headings

border     = #2a3140
danger     = #f7768e     errors, close button
warning    = #e0af68     warnings
link       = #7aa2f7     (= primary)
accent_alt = #bb9af7     (= accent)
```

## What Gets Deleted

```
themes/                          entire dir (9 theme variants)
templates/                       entire dir (13 .tpl files)
bin/zen0x-apply-theme
bin/zen0x-generate-theme
bin/zen0x-theme-menu
bin/zen0x-theme-reload
bin/zen0x-theme-set-vscode
.current-theme                   state file
```

Retained: `zen0x-powermenu`, `zen0x-toggle-*` (unrelated to theming).

## Static Files Created / Modified

Each file committed directly to the repo and deployed by stow.

| App | Repo path | Deployed to |
|-----|-----------|-------------|
| Hyprland colors | `hypr/colors.conf` | `~/.config/hypr/colors.conf` |
| Hyprlock | `hypr/hyprlock.conf` | `~/.config/hypr/hyprlock.conf` |
| AGS colors | `ags/style/colors.css` | `~/.config/ags/style/colors.css` |
| Kitty colors | `kitty/colors.conf` | `~/.config/kitty/colors.conf` |
| Nvim colors | `nvim/lua/zen0x/colors.lua` | `~/.config/nvim/lua/zen0x/colors.lua` |
| FastFetch | `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` |
| OpenCode theme | `opencode/themes/zen0x.json` | `~/.config/opencode/themes/zen0x.json` |
| OpenCode TUI | `opencode/tui.json` | `~/.config/opencode/tui.json` |

Waybar, Rofi, SwayNC, SwayOSD templates are deleted without replacement (replaced by AGS in recent commits).

## Per-App Notes

### Hyprland (`hypr/colors.conf`)
Static `$variable` definitions consumed by `40-look-and-feel.conf` via existing `source = ~/.config/hypr/colors.conf`. No change to look-and-feel.conf needed.

### AGS (`ags/style/colors.css`)
CSS custom properties (`@define-color`) already consumed by `bar.css`, `launcher.css`, `notifications.css`, `osd.css`. File becomes static — no generated header comment.

### Kitty (`kitty/colors.conf`)
Full 16-color terminal palette + foreground/background/selection/cursor. Sourced by `kitty.conf` via `include colors.conf`.

### Nvim (`nvim/lua/zen0x/colors.lua`)
Colors hardcoded directly. `zen0x` colorscheme (`nvim/colors/zen0x.lua`) kept unchanged — it still reads from this module. No change to plugin config.

### FastFetch (`fastfetch/config.jsonc`)
Color references in the config use ANSI escape codes or hex strings depending on what the current template generates. Rendered once as static file.

### OpenCode
`opencode/themes/zen0x.json` is a static copy of the theme JSON (full defs + theme sections) with hardcoded hex values. `opencode/tui.json` statically sets `"theme": "zen0x"` — previously written dynamically by `zen0x-theme-reload`.

## Stow Packages Affected

New stow packages added: `opencode` (if not already present).  
Existing packages `hypr`, `ags`, `kitty`, `nvim`, `fastfetch` gain static color files.

## Out of Scope

- VSCode theming (no replacement; `zen0x-theme-set-vscode` deleted)
- Wallpaper management (`awww` calls removed with `zen0x-theme-reload`)
- Any changes to Hyprland layout, input, or bind configs
