# Static Dark Theme Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the zen0x theme engine (Python generator, 9 theme variants, 13 templates, 5 bin scripts) and replace it with static, hardcoded dark theme files for every app.

**Architecture:** Each app gets a static color file committed directly to the repo and deployed by stow (or a symlink for nvim/ags). The AGS `colors.css` moves from the generated root location to `ags/style/colors.css` (already inside the stow-managed style symlink). No generation step — editing colors means editing files.

**Tech Stack:** bash, stow, CSS (`@define-color`), Hyprland conf, Kitty conf, Lua, JSON

---

## Color Palette Reference

Use these exact values throughout all tasks:

```
bg         = #0f1115
panel      = #151821   (bg-alt / panel / surface)
elevated   = #1a1f29   (surface-2 / elevated)
surface_2  = #212734   (further elevated, used sparingly)

fg         = #e6e9ef
muted      = #aab1bf
subtle     = #4a5568

accent     = #7aa2f7   (primary blue — borders, links, focus)
accent_alt = #bb9af7   (purple — highlights, headings)
success    = #9ece6a
warning    = #e0af68
danger     = #f7768e

border     = #2a3140
```

---

## File Map

| Action | Repo path | Deployed to |
|--------|-----------|-------------|
| Create | `hypr/colors.conf` | `~/.config/hypr/colors.conf` via stow |
| Create | `hypr/hyprlock.conf` | `~/.config/hypr/hyprlock.conf` via stow |
| Create | `ags/style/colors.css` | `~/.config/ags/style/colors.css` via existing style/ symlink |
| Modify | `ags/app.ts` | load CSS from new path |
| Create | `kitty/colors.conf` | `~/.config/kitty/colors.conf` via stow |
| Modify | `nvim/lua/zen0x/colors.lua` | hardcode colors; link via install.sh |
| Create | `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` via stow |
| Create | `opencode/themes/zen0x.json` | `~/.config/opencode/themes/zen0x.json` via stow |
| Create | `opencode/tui.json` | `~/.config/opencode/tui.json` via stow |
| Modify | `modules/stow.sh` | add opencode, add nvim colors.lua symlink step |
| Modify | `install.sh` | add opencode stow, add nvim symlink, remove theme step |
| Delete | `themes/` | entire directory |
| Delete | `templates/` | entire directory |
| Delete | `bin/zen0x-apply-theme` | — |
| Delete | `bin/zen0x-generate-theme` | — |
| Delete | `bin/zen0x-theme-menu` | — |
| Delete | `bin/zen0x-theme-reload` | — |
| Delete | `bin/zen0x-theme-set-vscode` | — |

---

## Task 1: Static Hyprland color files

**Files:**
- Create: `hypr/colors.conf`
- Create: `hypr/hyprlock.conf`

### Notes
`40-look-and-feel.conf` already has `source = ~/.config/hypr/colors.conf` — no changes needed there.  
`hyprlock.conf` previously lived only as a template; after this task it becomes a real stow-managed file.

- [ ] **Step 1: Create `hypr/colors.conf`**

```
# hyprland border / shadow colors — static dark theme
$active_border       = rgb(7aa2f7)
$inactive_border     = rgba(2a3140aa)
$shadow_color        = rgba(0f1115cc)
$shadow_inactive_color = rgba(0f111566)
```

- [ ] **Step 2: Create `hypr/hyprlock.conf`**

```
general {
    hide_cursor = true
    grace = 3
    no_fade_in = false
    no_fade_out = false
    ignore_empty_input = true
    text_trim = true
}

background {
    monitor =
    path = ~/.config/hypr/wallpaper.jpg
    blur_size = 8
    blur_passes = 4
    brightness = 0.60
    noise = 0.04
    contrast = 0.90
    vibrancy = 0.22
    vibrancy_darkness = 0.40
}

# Clock
label {
    monitor =
    text = cmd[update:1000] echo "<b>$(date +"%H:%M")</b>"
    color = rgba(e6e9efee)
    font_size = 112
    font_family = JetBrainsMono Nerd Font
    position = 0, 260
    halign = center
    valign = center
    shadow_passes = 3
    shadow_size = 6
    shadow_color = rgba(0f1115bb)
    shadow_boost = 1.2
}

# Date
label {
    monitor =
    text = cmd[update:60000] echo "$(date +"%A · %B %d, %Y")"
    color = rgba(aab1bfee)
    font_size = 24
    font_family = JetBrainsMono Nerd Font
    position = 0, 130
    halign = center
    valign = center
    shadow_passes = 2
    shadow_size = 4
    shadow_color = rgba(0f111599)
    shadow_boost = 1.1
}

# Divider
label {
    monitor =
    text = ─────────────────
    color = rgba(2a314066)
    font_size = 14
    font_family = JetBrainsMono Nerd Font
    position = 0, 40
    halign = center
    valign = center
}

# User
label {
    monitor =
    text =   $USER
    color = rgba(aab1bfcc)
    font_size = 17
    font_family = JetBrainsMono Nerd Font
    position = 0, -48
    halign = center
    valign = center
    shadow_passes = 1
    shadow_size = 3
    shadow_color = rgba(0f111588)
}

# Password input
input-field {
    monitor =
    size = 340, 58
    outline_thickness = 2
    dots_size = 0.30
    dots_spacing = 0.18
    dots_center = true
    dots_rounding = -1
    outer_color = rgba(7aa2f7cc)
    inner_color = rgba(0f1115bb)
    font_color = rgba(e6e9efff)
    font_family = JetBrainsMono Nerd Font
    fade_on_empty = true
    fade_timeout = 1200
    placeholder_text = <span foreground="##aab1bf"><i>󰌾  Password</i></span>
    hide_input = false
    rounding = 14
    check_color = rgba(9ece6aff)
    fail_color = rgba(f7768eff)
    fail_text = <span foreground="##f7768e"><b>$FAIL</b> ($ATTEMPTS)</span>
    fail_transition = 300
    capslock_color = rgba(e0af68ff)
    numlock_color = rgba(7aa2f7ff)
    bothlock_color = rgba(f7768eff)
    swap_font_color = false
    position = 0, -135
    halign = center
    valign = center
}

# Hint
label {
    monitor =
    text = Press Enter to unlock
    color = rgba(4a556888)
    font_size = 13
    font_family = JetBrainsMono Nerd Font
    position = 0, -215
    halign = center
    valign = center
}
```

- [ ] **Step 3: Verify stow would deploy both files correctly**

```bash
stow --dir=/home/aman/dotfiles --target=/home/aman/.config/hypr --stow hypr --simulate 2>&1
```

Expected: no errors. If conflicts exist for `colors.conf` or `hyprlock.conf` (previously generated), delete the existing files first:

```bash
rm -f ~/.config/hypr/colors.conf ~/.config/hypr/hyprlock.conf
```

- [ ] **Step 4: Commit**

```bash
git add hypr/colors.conf hypr/hyprlock.conf
git commit -m "feat(hypr): add static dark theme color files"
```

---

## Task 2: Static AGS colors.css + update app.ts

**Files:**
- Create: `ags/style/colors.css`
- Modify: `ags/app.ts:11` (the `loadCss` function)

### Notes
`~/.config/ags/style/` is already a symlink to `dotfiles/ags/style/`, so adding `colors.css` here requires no stow change. `app.ts` currently loads `colors.css` from `~/.config/ags/colors.css` (the old generated location) — update it to `~/.config/ags/style/colors.css`.

- [ ] **Step 1: Create `ags/style/colors.css`**

```css
@define-color bg       #0f1115;
@define-color panel    #151821;
@define-color panelAlt #151821;
@define-color elevated #1a1f29;
@define-color fg       #e6e9ef;
@define-color muted    #aab1bf;
@define-color subtle   #4a5568;
@define-color accent   #7aa2f7;
@define-color accentAlt #bb9af7;
@define-color success  #9ece6a;
@define-color warning  #e0af68;
@define-color danger   #f7768e;
@define-color border   #2a3140;
```

- [ ] **Step 2: Update `ags/app.ts` to load from new path**

In `ags/app.ts`, change the first line inside `loadCss`:

Old:
```typescript
  App.apply_css(`${HOME}/.config/ags/colors.css`, true)
```

New:
```typescript
  App.apply_css(`${HOME}/.config/ags/style/colors.css`, true)
```

- [ ] **Step 3: Remove old generated colors.css and verify AGS picks up the new one**

```bash
rm -f ~/.config/ags/colors.css
astal -i zen0x reload-css
```

Expected: AGS reloads without errors. Bar, launcher, notifications, OSD display correct dark colors.

- [ ] **Step 4: Commit**

```bash
git add ags/style/colors.css ags/app.ts
git commit -m "feat(ags): add static dark theme colors, load from style/"
```

---

## Task 3: Static Kitty colors.conf

**Files:**
- Create: `kitty/colors.conf`

### Notes
`kitty/kitty.conf` already has `include colors.conf` at line 10 — no changes needed.

- [ ] **Step 1: Create `kitty/colors.conf`**

```
foreground           #e6e9ef
background           #0f1115
selection_foreground #aab1bf
selection_background #1a1f29
url_color            #7aa2f7
cursor               #e6e9ef
cursor_text_color    #151821

# normal
color0  #0f1115
color1  #f7768e
color2  #9ece6a
color3  #e0af68
color4  #7aa2f7
color5  #bb9af7
color6  #73daca
color7  #aab1bf

# bright
color8  #2a3140
color9  #ff9e9e
color10 #b9f27c
color11 #fce094
color12 #a3c4f3
color13 #d4b6f4
color14 #9be0d2
color15 #e6e9ef
```

- [ ] **Step 2: Verify stow deploys correctly**

```bash
stow --dir=/home/aman/dotfiles --target=/home/aman/.config/kitty --stow kitty --simulate 2>&1
```

If `~/.config/kitty/colors.conf` exists (generated), delete it first:

```bash
rm -f ~/.config/kitty/colors.conf
```

Then stow and reload:
```bash
stow --dir=/home/aman/dotfiles --target=/home/aman/.config/kitty --stow kitty
pkill -SIGUSR1 kitty
```

Expected: Kitty reloads with correct colors.

- [ ] **Step 3: Commit**

```bash
git add kitty/colors.conf
git commit -m "feat(kitty): add static dark theme colors"
```

---

## Task 4: Hardcode Nvim colors.lua

**Files:**
- Modify: `nvim/lua/zen0x/colors.lua`

### Notes
`nvim/colors/zen0x.lua` (the colorscheme) reads from `require("zen0x.colors")` — it stays unchanged. Only the data file gets new hardcoded values. Deployment: `~/.config/nvim/` is not a stow package, so `install.sh` and `modules/stow.sh` get an explicit symlink step (Task 7).

- [ ] **Step 1: Replace contents of `nvim/lua/zen0x/colors.lua`**

```lua
return {
  bg          = "#0f1115",
  fg          = "#e6e9ef",
  surface     = "#151821",
  panel       = "#151821",
  panel_alt   = "#151821",
  elevated    = "#1a1f29",
  border      = "#2a3140",
  muted       = "#aab1bf",
  subtle      = "#4a5568",
  accent      = "#7aa2f7",
  accent_alt  = "#bb9af7",
  danger      = "#f7768e",
  success     = "#9ece6a",
  warning     = "#e0af68",
  red_light    = "#ff9e9e",
  red_dark     = "#f7768e",
  orange_light = "#ffb86c",
  orange_dark  = "#e0af68",
  yellow_light = "#fce094",
  yellow_dark  = "#e0af68",
  green_light  = "#b9f27c",
  green_dark   = "#9ece6a",
  teal_light   = "#9be0d2",
  teal_dark    = "#73daca",
  blue_light   = "#a3c4f3",
  blue_dark    = "#7aa2f7",
  purple_light = "#d4b6f4",
  purple_dark  = "#bb9af7",
  pink_light   = "#d4b6f4",
  pink_dark    = "#bb9af7",
  white        = "#e6e9ef",
  black        = "#0f1115",
}
```

- [ ] **Step 2: Symlink the new file into ~/.config/nvim**

```bash
mkdir -p ~/.config/nvim/lua/zen0x
ln -sf /home/aman/dotfiles/nvim/lua/zen0x/colors.lua ~/.config/nvim/lua/zen0x/colors.lua
```

- [ ] **Step 3: Verify colorscheme loads in nvim**

Open nvim, run:
```
:colorscheme zen0x
:lua print(require("zen0x.colors").bg)
```

Expected output: `#0f1115`

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/zen0x/colors.lua
git commit -m "feat(nvim): hardcode static dark theme colors"
```

---

## Task 5: Static FastFetch config.jsonc

**Files:**
- Create: `fastfetch/config.jsonc`

### Notes
The template had no color variables — output was pure JSON. This task just commits that JSON to the repo so stow can manage it.

- [ ] **Step 1: Create `fastfetch/config.jsonc`**

```jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

  "logo": {
    "type": "auto",
    "source": "~/.config/fastfetch/logo.txt"
  },

  "display": {
    "separator": " "
  },

  "modules": [
    { "type": "custom",   "format": "" },
    { "type": "os",       "key": "OS",  "keyWidth": 6 },
    { "type": "kernel",   "key": "KER", "keyWidth": 6 },
    { "type": "uptime",   "key": "UP",  "keyWidth": 6 },
    { "type": "packages", "key": "PKG", "keyWidth": 6 },
    { "type": "shell",    "key": "SH",  "keyWidth": 6 },
    { "type": "wm",       "key": "WM",  "keyWidth": 6 }
  ]
}
```

- [ ] **Step 2: Verify stow deploys correctly**

If `~/.config/fastfetch/config.jsonc` exists (generated), delete it first:
```bash
rm -f ~/.config/fastfetch/config.jsonc
```

Then re-stow:
```bash
stow --dir=/home/aman/dotfiles --target=/home/aman/.config/fastfetch --stow fastfetch
```

Run `fastfetch` to confirm it launches without errors.

- [ ] **Step 3: Commit**

```bash
git add fastfetch/config.jsonc
git commit -m "feat(fastfetch): add static config (previously generated)"
```

---

## Task 6: Static OpenCode theme

**Files:**
- Create: `opencode/themes/zen0x.json`
- Create: `opencode/tui.json`

- [ ] **Step 1: Create `opencode/themes/zen0x.json`**

```json
{
  "$schema": "https://opencode.ai/theme.json",
  "defs": {
    "bg":           "#0f1115",
    "surface":      "#151821",
    "panel":        "#151821",
    "panelAlt":     "#151821",
    "elevated":     "#1a1f29",
    "border":       "#2a3140",
    "borderActive": "#7aa2f7",
    "fg":           "#e6e9ef",
    "muted":        "#aab1bf",
    "subtle":       "#4a5568",
    "accent":       "#7aa2f7",
    "accentAlt":    "#bb9af7",
    "danger":       "#f7768e",
    "success":      "#9ece6a",
    "warning":      "#e0af68",
    "link":         "#7aa2f7",
    "red":          "#ff9e9e",
    "redDark":      "#f7768e",
    "pink":         "#d4b6f4",
    "purple":       "#bb9af7",
    "blue":         "#7aa2f7",
    "teal":         "#73daca",
    "green":        "#9ece6a",
    "yellow":       "#e0af68",
    "orange":       "#ffb86c",
    "grey050":      "#e6e9ef",
    "grey200":      "#aab1bf",
    "grey300":      "#6b7280",
    "grey350":      "#4a5568",
    "grey400":      "#374151",
    "grey500":      "#212734",
    "grey600":      "#1a1f29",
    "white":        "#e6e9ef",
    "black":        "#0f1115"
  },
  "theme": {
    "primary":    "accent",
    "secondary":  "teal",
    "accent":     "accentAlt",
    "error":      "danger",
    "warning":    "warning",
    "success":    "success",
    "info":       "blue",

    "text":       "fg",
    "textMuted":  "muted",

    "background":        "bg",
    "backgroundPanel":   "panel",
    "backgroundElement": "elevated",

    "border":       "border",
    "borderActive": "borderActive",
    "borderSubtle": "subtle",

    "diffAdded":               "green",
    "diffRemoved":             "red",
    "diffContext":             "fg",
    "diffHunkHeader":          "accent",
    "diffHighlightAdded":      "green",
    "diffHighlightRemoved":    "red",
    "diffAddedBg":             "grey400",
    "diffRemovedBg":           "grey400",
    "diffContextBg":           "bg",
    "diffLineNumber":          "muted",
    "diffAddedLineNumberBg":   "grey350",
    "diffRemovedLineNumberBg": "grey350",

    "markdownText":            "fg",
    "markdownHeading":         "accentAlt",
    "markdownLink":            "link",
    "markdownCode":            "teal",
    "markdownBlockQuote":      "muted",
    "markdownEmph":            "yellow",
    "markdownStrong":          "orange",
    "markdownHorizontalRule":  "border",
    "markdownListItem":        "fg",
    "markdownListEnumeration": "accent",
    "markdownImage":           "accent",
    "markdownImageText":       "muted",
    "markdownCodeBlock":       "teal",

    "syntaxComment":     "muted",
    "syntaxKeyword":     "purple",
    "syntaxFunction":    "blue",
    "syntaxVariable":    "fg",
    "syntaxString":      "green",
    "syntaxNumber":      "orange",
    "syntaxType":        "yellow",
    "syntaxOperator":    "teal",
    "syntaxPunctuation": "subtle"
  }
}
```

- [ ] **Step 2: Create `opencode/tui.json`**

```json
{
  "theme": "zen0x"
}
```

- [ ] **Step 3: Commit**

```bash
git add opencode/
git commit -m "feat(opencode): add static dark theme"
```

---

## Task 7: Update stow.sh and install.sh

**Files:**
- Modify: `modules/stow.sh`
- Modify: `install.sh`

### Notes
Two changes needed:
1. Add `opencode` to `CONFIG_PACKAGES` so `opencode/themes/zen0x.json` and `opencode/tui.json` are stowed.
2. Add an explicit symlink for `nvim/lua/zen0x/colors.lua` (nvim is not a standard stow package).
3. Remove the theme-apply step from `install.sh`.

- [ ] **Step 1: Update `modules/stow.sh`**

Find this line:
```bash
CONFIG_PACKAGES=(fastfetch hypr kitty quickshell rofi swayosd swaync waybar)
```

Replace with:
```bash
CONFIG_PACKAGES=(fastfetch hypr kitty opencode quickshell rofi swayosd swaync waybar)
```

Then add after the stow loop:

```bash
echo "Symlinking nvim/lua/zen0x/colors.lua → ~/.config/nvim/lua/zen0x/colors.lua ..."
mkdir -p "$HOME/.config/nvim/lua/zen0x"
ln -sf "$DOTFILES_DIR/nvim/lua/zen0x/colors.lua" "$HOME/.config/nvim/lua/zen0x/colors.lua"
```

- [ ] **Step 2: Update `install.sh` — add opencode to CONFIG_PACKAGES**

Find:
```bash
CONFIG_PACKAGES=(fastfetch hypr kitty rofi swayosd swaync waybar)
```

Replace with:
```bash
CONFIG_PACKAGES=(fastfetch hypr kitty opencode rofi swayosd swaync waybar)
```

- [ ] **Step 3: Update `install.sh` — add nvim symlink after the stow loop**

Find the line:
```bash
success "Stow done"
```

Add before it:
```bash
    info "nvim colors → ~/.config/nvim/lua/zen0x/colors.lua"
    mkdir -p "$HOME/.config/nvim/lua/zen0x"
    ln -sf "$DOTFILES_DIR/nvim/lua/zen0x/colors.lua" "$HOME/.config/nvim/lua/zen0x/colors.lua"
```

- [ ] **Step 4: Update `install.sh` — remove theme-apply step**

Remove these lines (around line 140–148):

```bash
# ── theme ──────────────────────────────────────────────────────────────────────
step "Apply default theme ($DEFAULT_THEME)"
if command -v zen0x-apply-theme >/dev/null 2>&1; then
    zen0x-apply-theme "$DEFAULT_THEME" || warn "Theme apply failed — run 'zen0x-apply-theme $DEFAULT_THEME' manually"
    success "Theme applied: $DEFAULT_THEME"
else
    warn "zen0x-apply-theme not in PATH yet — run it after logging in."
fi
```

Also remove the `DEFAULT_THEME` variable declaration near the top of `install.sh`:
```bash
DEFAULT_THEME="gruvbox"
```

Also remove any remaining references to `zen0x-theme-menu` in the success message at the bottom of `install.sh`:
```bash
printf "${GREEN}  Switch themes: zen0x-theme-menu${NC}\n"
```

- [ ] **Step 5: Commit**

```bash
git add modules/stow.sh install.sh
git commit -m "chore: update stow and install for static theme (add opencode, nvim symlink, remove theme step)"
```

---

## Task 8: Delete theme engine

**Files:**
- Delete: `themes/` (entire directory)
- Delete: `templates/` (entire directory)
- Delete: `bin/zen0x-apply-theme`
- Delete: `bin/zen0x-generate-theme`
- Delete: `bin/zen0x-theme-menu`
- Delete: `bin/zen0x-theme-reload`
- Delete: `bin/zen0x-theme-set-vscode`
- Delete: `.current-theme` (if it exists)

### Notes
`zen0x-powermenu` and `zen0x-toggle-*` scripts are **not** deleted.

- [ ] **Step 1: Delete all theme engine files**

```bash
git rm -r themes/ templates/
git rm bin/zen0x-apply-theme bin/zen0x-generate-theme bin/zen0x-theme-menu bin/zen0x-theme-reload bin/zen0x-theme-set-vscode
rm -f .current-theme
```

- [ ] **Step 2: Verify no remaining references to deleted scripts in tracked files**

```bash
grep -r "zen0x-apply-theme\|zen0x-generate-theme\|zen0x-theme-menu\|zen0x-theme-reload\|zen0x-theme-set-vscode" \
  --include="*.sh" --include="*.conf" --include="*.ts" --include="*.lua" \
  . 2>/dev/null
```

Expected: no output. If any references remain, fix them before committing.

- [ ] **Step 3: Also unlink deleted scripts from /usr/bin if previously stowed**

```bash
sudo rm -f /usr/bin/zen0x-apply-theme /usr/bin/zen0x-generate-theme \
           /usr/bin/zen0x-theme-menu /usr/bin/zen0x-theme-reload \
           /usr/bin/zen0x-theme-set-vscode
```

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: remove zen0x theme engine (themes, templates, generator scripts)"
```

---

## Task 9: Apply stow changes and verify live system

This task applies all stow changes to the live system and verifies everything works.

- [ ] **Step 1: Re-stow hypr, kitty, fastfetch to pick up new static color files**

Remove any previously-generated files that would conflict:
```bash
rm -f ~/.config/hypr/colors.conf ~/.config/hypr/hyprlock.conf
rm -f ~/.config/kitty/colors.conf
rm -f ~/.config/fastfetch/config.jsonc
rm -f ~/.config/opencode/tui.json
```

Then re-stow:
```bash
stow --dir=/home/aman/dotfiles --target=/home/aman/.config/hypr --stow hypr
stow --dir=/home/aman/dotfiles --target=/home/aman/.config/kitty --stow kitty
stow --dir=/home/aman/dotfiles --target=/home/aman/.config/fastfetch --stow fastfetch
mkdir -p ~/.config/opencode/themes
stow --dir=/home/aman/dotfiles --target=/home/aman/.config/opencode --stow opencode
```

- [ ] **Step 2: Symlink nvim colors**

```bash
mkdir -p ~/.config/nvim/lua/zen0x
ln -sf /home/aman/dotfiles/nvim/lua/zen0x/colors.lua ~/.config/nvim/lua/zen0x/colors.lua
```

- [ ] **Step 3: Reload Hyprland**

```bash
hyprctl reload
```

Expected: no errors. Borders use `#7aa2f7` (soft blue).

- [ ] **Step 4: Reload AGS**

```bash
astal -i zen0x reload-css
```

Expected: bar, launcher, OSD reload with dark theme colors.

- [ ] **Step 5: Reload Kitty**

```bash
pkill -SIGUSR1 kitty
```

Expected: Kitty reloads colors.

- [ ] **Step 6: Verify Nvim colorscheme**

Open nvim, run `:colorscheme zen0x`. Confirm correct dark background and colors load with no warning.

- [ ] **Step 7: Final commit if any last tweaks were made**

```bash
git add -p
git commit -m "chore: final cleanup after static theme migration"
```
