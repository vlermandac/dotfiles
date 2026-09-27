---@param s string
local function fail(s, ...)
	ya.notify({ title = "clipboard-image", content = string.format(s, ...), timeout = 3, level = "error" })
end

---@param s string
local function info(s, ...)
	ya.notify({ title = "clipboard-image", content = string.format(s, ...), timeout = 3, level = "info" })
end

---@return string?
local hovered_file = ya.sync(function()
	local hovered = cx.active.current.hovered
	return hovered and tostring(hovered.url) or nil
end)

return {
	entry = function()
		local file = hovered_file()
		if not file then
			fail("Hover a single image file first.")
			return
		end

		local mime_out, mime_err = Command("/bin/file")
			:arg({ "--brief", "--mime-type", "--dereference", file })
			:stdout(Command.PIPED)
			:output()

		if not mime_out then
			fail("Cannot determine MIME type, error code %s.", mime_err)
			return
		end

		local mime = (mime_out.stdout or ""):gsub("%s+$", "")
		if not mime:match("^image/") then
			fail("Hovered file is not an image (%s).", mime ~= "" and mime or "unknown")
			return
		end

		local script = [[
mime="$(/bin/file --brief --mime-type --dereference "$1")" || exit 2
case "$mime" in
	image/*) /bin/magick "$1" png:- | /bin/wl-copy --type image/png ;;
	*) exit 3 ;;
esac
]]

		local child, spawn_err = Command("/bin/bash")
			:arg({ "-lc", script, "_", file })
			:spawn()

		if not child then
			fail("Spawn `wl-copy` failed with error code %s.", spawn_err)
			return
		end

		local output, wait_err = child:wait_with_output()
		if not output then
			fail("Cannot read `wl-copy` output, error code %s.", wait_err)
			return
		end

		if not output.status.success then
			if output.status.code == 3 then
				fail("Hovered file is not an image.")
			else
				fail("`wl-copy` exited with error code %s.", output.status.code)
			end
			return
		end

		info("Copied image data to clipboard.")
	end,
}
