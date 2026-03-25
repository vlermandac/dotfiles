local mp = require 'mp'

-- Function to toggle secondary-sid
local function toggle_secondary_sid()
    local current_sid = mp.get_property_native("secondary-sid", "no") -- Default to "no" if not set
    if current_sid == 1 then
        mp.set_property("secondary-sid", "no") -- Disable secondary subtitle
        mp.osd_message("Secondary Subtitle: OFF")
    else
        mp.set_property("secondary-sid", "1") -- Enable secondary subtitle
        mp.osd_message("Secondary Subtitle: ON (SID 1)")
    end
end

-- Bind function to script-message for keybinding
mp.register_script_message("toggle-secondary-sid", toggle_secondary_sid)
