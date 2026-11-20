local home = os.getenv("HOME") or ""
local lua_root = home .. "/.config/hypr/lua"

package.path = table.concat({
    lua_root .. "/?.lua",
    lua_root .. "/?/init.lua",
    package.path,
}, ";")

local function safe_require(module)
    local ok, result = pcall(require, module)
    if not ok then
        print(string.format("[hyprland.lua] failed to load %s: %s", module, result))
        return nil
    end

    return result
end

for _, module in ipairs({
    "hypr.modules.monitors",
    "hypr.modules.workspace_layouts",
    "hypr.modules.startup",
    "hypr.modules.theme",
    "hypr.modules.misc",
    "hypr.modules.input",
    "hypr.modules.keybinds",
    "hypr.modules.desktop_tools",
    "hypr.modules.rules",
}) do
    safe_require(module)
end
