local home = os.getenv("HOME") or ""

local M = {
    terminal = "kitty",
    file_manager = "thunar",
    menu = "rofi -show drun -show-icons -theme rounded-template",
    main_mod = "SUPER",
    monitors = {
        vertical = "HDMI-A-1",
        horizontal = "DP-3",
    },
    paths = {
        launcher = home .. "/Workspace/Projects/system/unified-quickshell/scripts/toggle-launcher",
        browser_omnibar = home .. "/Workspace/Projects/system/unified-quickshell/scripts/toggle-browser-omnibar",
        wallpaper_picker = home .. "/Workspace/Projects/system/unified-quickshell/scripts/toggle-wallpaper-picker",
        screenshot = home .. "/.local/bin/hyprshot-region-trim.sh",
        brightness = home .. "/.local/bin/monitor-brightness-sync.sh",
        blue_light = home .. "/.local/bin/toggle-blue-light.sh",
        ardour_knob_scroll = home .. "/.config/hypr/scripts/ardour-knob-scroll.py",
        start_media_stack = home .. "/.config/hypr/scripts/start-media-stack.sh",
        session_bootstrap = home .. "/.config/hypr/scripts/session-bootstrap.sh",
        theme_refresh = home .. "/.local/bin/refresh-session-theme.sh",
    },
}

function M.shell(command)
    return "sh -lc " .. string.format("%q", command)
end

function M.exec_shell(command)
    hl.exec_cmd(M.shell(command))
end

function M.dsp_shell(command)
    return hl.dsp.exec_cmd(M.shell(command))
end

local function vector_value(vector, axis, index)
    if vector == nil then
        return nil
    end

    return vector[axis] or vector[index]
end

function M.move_cursor_to_active_window()
    local window = hl.get_active_window()
    if window == nil or window.at == nil or window.size == nil then
        return
    end

    local class = string.lower(tostring(window.class or window.initialClass or ""))
    local x_ratio = 0.5

    -- Brave's hidden vertical tabs can open on side hover. Land safely inside it.
    if class:find("brave", 1, true) then
        x_ratio = 0.35
    end

    local at_x = vector_value(window.at, "x", 1)
    local at_y = vector_value(window.at, "y", 2)
    local width = vector_value(window.size, "x", 1)
    local height = vector_value(window.size, "y", 2)

    if at_x == nil or at_y == nil or width == nil or height == nil then
        return
    end

    local x = math.floor(at_x + (width * x_ratio))
    local y = math.floor(at_y + (height / 2))

    hl.dispatch(hl.dsp.cursor.move({ x = x, y = y }))
end

function M.focus_with_cursor(opts)
    return function()
        hl.dispatch(hl.dsp.focus(opts))
        hl.timer(function()
            M.move_cursor_to_active_window()
        end, { timeout = 25, type = "oneshot" })
    end
end

function M.monitor_aware_window_focus(horizontal_direction, vertical_direction)
    return function()
        if M.active_on(M.monitors.vertical) then
            -- Generic geometric left/right focus can skip off-screen targets on
            -- a vertical scrolling tape. Use the layout's primary axis instead.
            hl.dispatch(hl.dsp.layout("focus " .. vertical_direction))
            return
        end

        hl.dispatch(hl.dsp.focus({ direction = horizontal_direction }))
        hl.timer(function()
            M.move_cursor_to_active_window()
        end, { timeout = 25, type = "oneshot" })
    end
end

function M.toggle_split_or_scrolling_stack()
    return function()
        local workspace = hl.get_active_workspace()

        if workspace ~= nil and workspace.tiled_layout == "scrolling" then
            hl.dispatch(hl.dsp.layout("consume_or_expel prev"))
            return
        end

        hl.dispatch(hl.dsp.layout("togglesplit"))
    end
end

function M.active_monitor_name()
    local monitor = hl.get_active_monitor()
    return monitor and monitor.name or nil
end

function M.active_on(name)
    return M.active_monitor_name() == name
end

function M.launch_terminal()
    if M.active_on(M.monitors.vertical) then
        M.exec_shell([[kitty --override "font_size=17"]])
        return
    end

    hl.exec_cmd(M.terminal)
end

return M
