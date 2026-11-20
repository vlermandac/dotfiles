local home = os.getenv("HOME") or ""
local path = home .. "/.config/hypr/workspace-layouts.tsv"
local file = io.open(path, "r")

if file == nil then
    return
end

for line in file:lines() do
    if not line:match("^%s*#") and not line:match("^%s*$") then
        local workspace, layout = line:match("^([^\t]+)\t([^\t]+)$")

        if workspace
            and layout
            and not workspace:match("^special:")
            and layout:match("^[%w:_-]+$")
        then
            hl.workspace_rule({
                workspace = workspace,
                layout = layout,
            })
        end
    end
end

file:close()
