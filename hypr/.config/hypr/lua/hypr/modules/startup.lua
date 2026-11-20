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

-- (AI-assisted) Session startup is owned by unified-quickshell: its module restarts
-- unified-session.target on hyprland.start and stops it on shutdown. systemd orders the
-- environment import, Waywallen, the shell and the personal units in desktop-session.
-- Fallback for a machine where scripts/install-session has not linked the module yet: the
-- previous bash bootstrap, so a missing install never leaves an empty desktop.
local session_module = home .. "/.config/unified-quickshell/hyprland.lua"
local loaded, load_error = pcall(dofile, session_module)
if not loaded then
    print("unified session module unavailable (" .. tostring(load_error) .. "); using session-bootstrap")
    hl.on("hyprland.start", function()
        hl.exec_cmd("systemctl --user restart unified-session-bootstrap.service")
    end)
    hl.on("hyprland.shutdown", function()
        hl.exec_cmd("systemctl --user stop unified-session-bootstrap.service unified-quickshell.service waywallen.service")
    end)
end
