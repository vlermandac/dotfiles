local settings = require("hypr.settings")

local main_mod = settings.main_mod

hl.bind(main_mod .. " + RETURN", function()
	settings.launch_terminal()
end)
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(
	main_mod .. " + M",
	settings.dsp_shell("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")
)
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(settings.file_manager))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + SPACE", hl.dsp.exec_cmd(settings.paths.launcher))
hl.bind(main_mod .. " + O", hl.dsp.exec_cmd(settings.paths.browser_omnibar))
-- (AI-assisted) Reserved Ask AI action; currently a silent placeholder.
hl.bind(main_mod .. " + A", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/ask-ai"))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/desktop-bitwarden"))
hl.bind(main_mod .. " + ALT + C", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/send-clipboard-to-phone"))
hl.bind(main_mod .. " + SHIFT + T", hl.dsp.exec_cmd(settings.paths.wallpaper_picker))
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
hl.bind(main_mod .. " + R", settings.toggle_split_or_scrolling_stack())

hl.bind(main_mod .. " + H", settings.monitor_aware_window_focus("left", "d"))
hl.bind(main_mod .. " + L", settings.monitor_aware_window_focus("right", "u"))
hl.bind(main_mod .. " + ALT + J", hl.dsp.focus({ direction = "down" }))
hl.bind(main_mod .. " + ALT + K", hl.dsp.focus({ direction = "up" }))
hl.bind("ALT + TAB", hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-alt-tab next"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-alt-tab prev"))
hl.bind("ALT + H", settings.focus_with_cursor({ monitor = "l" }))
hl.bind("ALT + L", settings.focus_with_cursor({ monitor = "r" }))

hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

for workspace = 1, 10 do
	local key = workspace % 10
	hl.bind(main_mod .. " + " .. key, settings.focus_with_cursor({ workspace = workspace }))
	hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(main_mod .. " + S", hl.dsp.window.pin())
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.exec_cmd(settings.paths.screenshot))
hl.bind(main_mod .. " + BACKSLASH", hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-tray-toggle"))
hl.bind(main_mod .. " + SHIFT + BACKSLASH", hl.dsp.window.move({ workspace = "special:tray" }))

hl.bind(main_mod .. " + mouse_down", settings.focus_with_cursor({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", settings.focus_with_cursor({ workspace = "e-1" }))

hl.bind(main_mod .. " + J", settings.focus_with_cursor({ workspace = "m-1" }))
hl.bind(main_mod .. " + K", settings.focus_with_cursor({ workspace = "m+1" }))

local function workspace_selector(workspace)
	if workspace.special then
		return workspace.name
	end

	if workspace.id > 0 then
		return tostring(workspace.id)
	end

	return "name:" .. workspace.name
end

local workspace_gap_values = {}

local function adjust_workspace_gap(name, delta)
	local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
	if workspace == nil then
		return
	end

	local selector = workspace_selector(workspace)
	local values = workspace_gap_values[selector]
	if values == nil then
		values = {}
		workspace_gap_values[selector] = values
	end

	if values[name] == nil then
		values[name] = hl.get_config("general." .. name).top
	end

	values[name] = math.max(0, math.min(50, values[name] + delta))
	local rule = {
		workspace = selector,
	}

	rule[name] = values[name]
	hl.workspace_rule(rule)
end

hl.bind(main_mod .. " + bracketleft", function()
	adjust_workspace_gap("gaps_in", -2)
end, { repeating = true })

hl.bind(main_mod .. " + bracketright", function()
	adjust_workspace_gap("gaps_in", 2)
end, { repeating = true })

hl.bind(main_mod .. " + SHIFT + bracketleft", function()
	adjust_workspace_gap("gaps_out", -2)
end, { repeating = true })

hl.bind(main_mod .. " + SHIFT + bracketright", function()
	adjust_workspace_gap("gaps_out", 2)
end, { repeating = true })

hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

local function ardour_is_active()
	local window = hl.get_active_window()
	if window == nil then
		return false
	end

	local class = string.lower(tostring(window.class or window.initialClass or ""))
	return class == "ardour" or class:find("ardour", 1, true) ~= nil
end

local function ardour_knob_scroll(direction)
	return function()
		if not ardour_is_active() then
			return { ok = false }
		end

		hl.dispatch(hl.dsp.exec_cmd(settings.paths.ardour_knob_scroll .. " " .. direction))
		return { ok = true }
	end
end

hl.bind(
	"CTRL + XF86AudioLowerVolume",
	ardour_knob_scroll("left"),
	{
		auto_consuming = true,
		repeating = true,
		description = "Ardour: small horizontal scroll left",
	}
)
hl.bind(
	"CTRL + XF86AudioRaiseVolume",
	ardour_knob_scroll("right"),
	{
		auto_consuming = true,
		repeating = true,
		description = "Ardour: small horizontal scroll right",
	}
)

hl.bind(main_mod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd(settings.paths.brightness .. " +10"))
hl.bind(main_mod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd(settings.paths.brightness .. " -10"))
hl.bind(main_mod .. " + Page_Up", hl.dsp.exec_cmd(settings.paths.brightness .. " +10"))
hl.bind(main_mod .. " + Page_Down", hl.dsp.exec_cmd(settings.paths.brightness .. " -10"))
hl.bind(main_mod .. " + XF86AudioMute", hl.dsp.exec_cmd(settings.paths.blue_light))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(main_mod .. " + X", hl.dsp.exec_cmd("quickshell ipc -p /home/vlermanda/Workspace/Projects/system/unified-quickshell/shell call shell dismissNotificationPopups"))

hl.bind("CTRL + SHIFT + 2", hl.dsp.global("com.t3tools.T3Code:capture-window"))
