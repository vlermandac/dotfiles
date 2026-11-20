local home = os.getenv("HOME") or ""
local settings = require("hypr.settings")
local main_mod = settings.main_mod

local function script(name)
	return home .. "/.local/bin/" .. name
end

-- (AI-assisted) Native Tools tab; keep the query free for individual tool prefixes.
hl.bind(main_mod .. " + ALT + SPACE", hl.dsp.exec_cmd(os.getenv("HOME") .. "/Workspace/Projects/system/unified-quickshell/scripts/toggle-tools"))
hl.bind(main_mod .. " + ALT + O", hl.dsp.exec_cmd(script("browser-omnibar")))
