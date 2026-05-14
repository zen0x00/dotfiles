hl.config({
    general = {
        gaps_in = 10,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = active_border,
            inactive_border = inactive_border,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 12,
        rounding_power = 4,
        active_opacity = 0.92,
        inactive_opacity = 0.82,
        fullscreen_opacity = 1.0,
        dim_inactive = true, dim_strength = 0.08, dim_special = 0.12,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true, vibrancy = 0.15,
        },
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true,
        focus_on_activate = true,
    },
})

hl.curve("out", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("back", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
hl.curve("in", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "windows",      enabled = true, speed = 3, bezier = "back",  style = "popin 85%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 2, bezier = "in",    style = "popin 95%" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 2, bezier = "out",   style = "slide" })
hl.animation({ leaf = "border",       enabled = true, speed = 2, bezier = "out" })
hl.animation({ leaf = "fade",         enabled = true, speed = 2, bezier = "out" })
hl.animation({ leaf = "fadeLayers",   enabled = true, speed = 2, bezier = "out" })
hl.animation({ leaf = "layers",       enabled = true, speed = 2, bezier = "out",   style = "fade" })
hl.animation({ leaf = "layersOut",    enabled = true, speed = 1, bezier = "in",    style = "fade" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 3, bezier = "out",   style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "out", style = "slidevert" })
