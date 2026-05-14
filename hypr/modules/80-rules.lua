
-- Blur layer surfaces
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0.2 })

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize"
})

hl.window_rule({
    name = "polished-common-dialogs",
    match = { title = "^(Open|Save|Save As|Choose|Select|File Upload)(.*)$" },
    float = true,
    center = true,
    size = "60% 65%",
})

hl.window_rule({
    name = "polished-picture-in-picture",
    match = { title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true,
    pin = true,
    size = "30% 30%",
    move = "69% 64%",
    opacity = "1.0 1.0"
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true
})

-- Float Steam
hl.window_rule({ match = { class = "steam" }, float = true })
hl.window_rule({ match = { class = "steam", title = "Steam" }, center = true })
hl.window_rule({ match = { class = "steam.*" }, opacity = "1 1" })
hl.window_rule({ match = { class = "steam", title = "Steam" }, size = "1400 800" })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, size = "460 800" })
hl.window_rule({ match = { class = "steam" }, idle_inhibit = "fullscreen" })

-- Remove 1px border around hyprshot screenshots
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })

hl.window_rule({
    match = { class = "^(app.mist.Mist|org.gnome.Nautilus)$", fullscreen = false },
    float = true,
    center = true,
    size = "1100 700",
    rounding = 16
})

hl.window_rule({
    name = "float-vlc",
    match = { class = "^(vlc|VLC)$" },
    float = true,
    center = true,
    size = "1280 720"
})

hl.window_rule({
    match = { class = "^(unityhub-bin)$", fullscreen = false },
    float = true,
    center = true,
    size = "1100 700"
})

hl.window_rule({
    name = "center-unity-dialogs",
    match = { title = "^(Fatal Error!|Enter Safe Mode?|Unity Bug Reporter|Delete selected asset?)$" },
    float = true,
    center = true
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true
})

hl.window_rule({
    name = "float-rofi",
    match = { class = "^[Rr]ofi$" },
    float = true,
    center = true,
})


-- Workspace assignments

hl.window_rule({
    name = "ws1-zen-browser",
    match = { class = "^(zen|Zen)$" },
    workspace = 1
})

hl.window_rule({
    name = "ws2-terminal",
    match = { class = "^(kitty|Kitty|Alacritty|WezTerm|foot)$" },
    workspace = 2
})

hl.window_rule({
    name = "ws3-vscode",
    match = { class = "^(code|Code|vscode|VSCode)$" },
    workspace = 3
})

hl.window_rule({
    name = "ws4-unity",
    match = { class = "^(unityhub|Unity)" },
    workspace = 4
})

hl.window_rule({
    name = "ws5-steam-heroic",
    match = { class = "^(steam|Steam|heroic|Heroic)$" },
    workspace = 5
})

hl.window_rule({
    name = "ws6-games",
    match = { title = "^(.*%.exe|.*game|.*Game)$" },
    workspace = 6
})
