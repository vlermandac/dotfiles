local settings = require("hypr.settings")
local home = os.getenv("HOME") or ""
local inherited_path = os.getenv("PATH") or ""
local user_bin = home .. "/.local/bin"
local session_path = inherited_path
local data_home = os.getenv("XDG_DATA_HOME") or (home .. "/.local/share")
local cache_home = os.getenv("XDG_CACHE_HOME") or (home .. "/.cache")

if not (":" .. inherited_path .. ":"):find(":" .. user_bin .. ":", 1, true) then
    session_path = user_bin .. (inherited_path ~= "" and ":" .. inherited_path or "")
end

for _, entry in ipairs({
    { "PATH", session_path },
    -- Keep direct compositor launches aligned with environment.d/70-xdg-app-paths.conf.
    { "RUSTUP_HOME", data_home .. "/rustup" },
    { "CUDA_CACHE_PATH", cache_home .. "/nvidia/ComputeCache" },
    { "IMPECCABLE_HOME", cache_home .. "/impeccable" },
    { "IMPECCABLE_UPDATE_CACHE", cache_home .. "/impeccable/update-check.json" },
    { "IMPECCABLE_STALENESS_CACHE", cache_home .. "/impeccable/staleness-check.json" },
    { "IMPECCABLE_CACHE_ROOT", cache_home .. "/impeccable/hooks" },
    { "GNUPGHOME", data_home .. "/gnupg" },
    { "XCURSOR_SIZE", "24" },
    { "HYPRCURSOR_SIZE", "24" },
    { "LANG", "en_US.UTF-8" },
    { "LC_TIME", "en_US.UTF-8" },
    { "LC_NUMERIC", "en_US.UTF-8" },
    { "LC_MONETARY", "en_US.UTF-8" },
    { "LC_PAPER", "en_US.UTF-8" },
    { "LC_NAME", "en_US.UTF-8" },
    { "LC_ADDRESS", "en_US.UTF-8" },
    { "LC_TELEPHONE", "en_US.UTF-8" },
    { "LC_MEASUREMENT", "en_US.UTF-8" },
    { "LC_IDENTIFICATION", "en_US.UTF-8" },
    { "GTK_THEME", "Adwaita:dark" },
    { "QT_QPA_PLATFORMTHEME", "gtk3" },
}) do
    hl.env(entry[1], entry[2])
end

-- Hyprland 0.55+ documents the hyprland.start event as the Lua equivalent of exec-once.
-- Run the bootstrap as a supervised user unit so a boot-time Wayland-socket race is retried and
-- failures are visible in the user journal instead of silently leaving an empty desktop.
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user restart unified-session-bootstrap.service")
end)

hl.on("hyprland.shutdown", function()
    hl.exec_cmd("systemctl --user stop unified-session-bootstrap.service unified-quickshell.service waywallen.service")
end)
