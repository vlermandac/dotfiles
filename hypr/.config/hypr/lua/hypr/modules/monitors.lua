hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@74.97",
    position = "0x0",
    scale = 1,
    transform = 1,
})

hl.monitor({
    output = "DP-3",
    mode = "1920x1080@280",
    position = "1080x360",
    scale = 1,
})

hl.workspace_rule({
    workspace = "1",
    monitor = "HDMI-A-1",
    persistent = true,
    default = true,
    layout = "scrolling",
    layout_opts = { direction = "up" },
})

hl.workspace_rule({
    workspace = "2",
    monitor = "HDMI-A-1",
    persistent = true,
    layout = "scrolling",
    layout_opts = { direction = "up" },
})

hl.workspace_rule({
    workspace = "3",
    monitor = "DP-3",
    persistent = true,
    default = true,
    layout = "scrolling",
    layout_opts = { direction = "right" },
})

hl.workspace_rule({
    workspace = "4",
    monitor = "DP-3",
    persistent = true,
    layout = "scrolling",
    layout_opts = { direction = "right" },
})

for workspace = 5, 9 do
    hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = "DP-3",
    })
end

hl.workspace_rule({
    workspace = "special:tray",
    layout = "dwindle",
    gaps_in = 31,
    gaps_out = 38,
})
