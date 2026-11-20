hl.config({
    cursor = {
        no_warps = false,
    },

    input = {
        kb_layout = "us",
        kb_variant = "intl",
        follow_mouse = 0,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})
