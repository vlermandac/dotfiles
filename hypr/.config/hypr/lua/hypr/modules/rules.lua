local suppress_maximize_rule = hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

suppress_maximize_rule:set_enabled(true)

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "xwayland-video-bridge-fixes",
    match = { class = "xwaylandvideobridge" },
    no_initial_focus = true,
    no_focus = true,
    no_anim = true,
    no_blur = true,
    max_size = "1 1",
    opacity = "0.0 0.0 1.0",
})

hl.window_rule({
    name = "kitty-opacity",
    match = { class = "kitty" },
    opacity = "0.90 0.90 1.0",
})

hl.window_rule({
    name = "thunderbird-compose-floating",
    match = {
        class = "^(org[.]mozilla[.]Thunderbird|thunderbird-beta)$",
        initial_title = "^Write:.*",
    },
    float = true,
    size = "(monitor_w*0.75) (monitor_h*0.80)",
    center = true,
})

hl.window_rule({
    name = "rofi-quick-note",
    match = { class = "rofi-quick-note" },
    float = true,
    pin = true,
    size = "500 290",
    move = "monitor_w-520 48",
    opacity = "0.96 0.96 1.0",
})

hl.window_rule({
    name = "tray-thunderbird",
    match = {
        class = "^(org[.]mozilla[.]Thunderbird|thunderbird-beta)$",
        initial_title = "^Mozilla Thunderbird( Beta)?$",
    },
    workspace = "special:tray silent",
    tile = true,
})

hl.window_rule({
    name = "tray-telegram",
    match = {
        class = "^org[.]telegram[.]desktop$",
        initial_title = "^Telegram$",
    },
    workspace = "special:tray silent",
    tile = true,
})

hl.window_rule({
    name = "tray-rmpc",
    match = { class = "^tray-rmpc$" },
    workspace = "special:tray silent",
    tile = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

hl.layer_rule({
    name = "rofi-animation",
    match = { namespace = "^rofi$" },
    animation = "popin 87%",
})

-- External Gemini web panel; Hyprland owns its floating-window lifecycle.
dofile(os.getenv("HOME") .. "/.config/gemini-web-panel/hyprland.lua")
