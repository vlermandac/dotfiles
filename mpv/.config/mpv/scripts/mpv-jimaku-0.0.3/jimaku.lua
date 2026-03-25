local utils = require "mp.utils"
local mpi = require "mp.input"

-- API Key (Replace with your actual Jimaku API Key)
local API_KEY = "YOUR_API_KEY_GOES_HERE"

-- Config options
local PROMPT_EPISODE = true
local MANUAL_SEARCH_KEY = "g"
local FILENAME_AUTO_SEARCH_KEY = "h"
local PARENT_FOLDER_AUTO_SEARCH_KEY = "n"

--------------------------------------------------------------------------------
-- Input wrapper functions to work around an mpv input bug.
--------------------------------------------------------------------------------
local function input_get(args)
    mpi.terminate()
    -- Use a short delay so that the input console resets properly
    mp.add_timeout(0.01, function() mpi.get(args) end)
end

local function input_select(args)
    mpi.terminate()
    mp.add_timeout(0.01, function() mpi.select(args) end)
end

--------------------------------------------------------------------------------
-- Helper function: URL-encode a string.
--------------------------------------------------------------------------------
local function urlencode(str)
    if str then
        str = string.gsub(str, "([^%w%-%.%_%~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
    end
    return str
end

--------------------------------------------------------------------------------
-- Helper function: send an API request using curl and parse the JSON reply.
--------------------------------------------------------------------------------
local function api(url)
    local command = {
        "curl",
        "-s",
        "--url", url,
        "--header", "Authorization: " .. API_KEY,
    }

    local res = mp.command_native({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
        args = command
    })

    if res.stdout and res.stdout ~= "" then
        local parsed = utils.parse_json(res.stdout)
        if parsed and parsed.error then
            mp.osd_message("API Error: " .. tostring(parsed.error), 2)
            return nil
        end
        return parsed
    else
        return nil
    end
end

--------------------------------------------------------------------------------
-- Helper function: download subtitles using curl.
-- Returns the filename where the subtitle was saved.
--------------------------------------------------------------------------------
local function download_sub(sub)
    local command = {
        "curl",
        "-s",
        "--url", sub.url,
        "--output", sub.name,
    }

    mp.command_native({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        args = command
    })

    return sub.name
end

--------------------------------------------------------------------------------
-- Helper function: display a message on mpv's OSD.
--------------------------------------------------------------------------------
local function show_message(message, persist)
    local duration = persist and 999 or 2
    mp.osd_message(message, duration)
end

--------------------------------------------------------------------------------
-- Helper function: sanitize filenames for better search matching.
--------------------------------------------------------------------------------
local function sanitize(text)
    local patterns = {
        "%.[a-zA-Z]+$",   -- file extension at end
        "%.",             -- dots anywhere
        "-",              -- hyphens
        "_",              -- underscores
        "%[.-%]",        -- content inside square brackets
        "%(.-%)",        -- content inside parentheses
        "720[pP]",
        "480[pP]",
        "1080[pP]",
        "[xX]26[45]",
        "[bB]lu[-]?[rR]ay",
        "^[%s]*",        -- leading spaces
        "[%s]*$",        -- trailing spaces
        "1920x1080",
        "1920X1080",
        "Hi10P",
        "FLAC",
        "AAC"
    }
    
    for _, pattern in ipairs(patterns) do
        text = text:gsub(pattern, " ")
    end
    return text
end

--------------------------------------------------------------------------------
-- Helper function: extract a title from a (possibly messy) filename.
--------------------------------------------------------------------------------
local function extract_title(text)
    local matchers = {
        { "([%w%s%d]+)[Ss]%d+[Ee]?%d+", 1 },
        { "([%w%s%d]+)%s*%-[%s]*%d+[^%w]*$", 1 },
        { "([%w%s%d]+)[Ee]?[Pp]?%s+%d+$", 1 },
        { "([%w%s%d]+)%s+%d+.*$", 1 },
        { "^%d+[%s]*(.+)$", 1 }
    }

    for _, matcher in ipairs(matchers) do
        local match = text:match(matcher[1])
        if match then return match:gsub("^%s*(.-)%s*$", "%1") end
    end

    return text
end

--------------------------------------------------------------------------------
-- Function: handle subtitle selection (download and load).
--------------------------------------------------------------------------------
local function select_sub(sub)
    if not sub then
        show_message("Invalid subtitle selection", false)
        return
    end

    local file = download_sub(sub)
    mp.commandv("sub_add", file)
    show_message("Subtitle downloaded and added: " .. file, false)
    -- Unpause playback after adding subtitles
    mp.set_property("pause", "no")
end

--------------------------------------------------------------------------------
-- Function: prompt for an episode number and fetch subtitles.
--------------------------------------------------------------------------------
local function select_episode(anime)
    input_get({
        prompt = "Enter episode number (leave blank for all): ",
        submit = function(episode)
            local url = "https://jimaku.cc/api/entries/" .. anime.id .. "/files"
            if episode and episode ~= "" then
                url = url .. "?episode=" .. urlencode(episode)
            end

            local ep_str = (episode and episode ~= "") and episode or "all"
            show_message("Fetching subs for: " .. anime.name .. " episode " .. ep_str)
            local results = api(url)

            if not results or (#results == 0) then
                show_message("No results found", false)
                return
            end

            if #results == 1 then
                select_sub(results[1])
                return
            end

            -- If multiple results, let the user choose one.
            local sub_names = {}
            for _, sub in ipairs(results) do
                table.insert(sub_names, sub.name)
            end

            input_select({
                prompt = "Select subtitle file: ",
                items = sub_names,
                submit = function(index)
                    select_sub(results[index])
                end
            })
        end
    })
end

--------------------------------------------------------------------------------
-- Function: process the selected anime.
--------------------------------------------------------------------------------
local function on_anime_selected(anime)
    if PROMPT_EPISODE then
        select_episode(anime)
    else
        local url = "https://jimaku.cc/api/entries/" .. anime.id .. "/files"
        local results = api(url)

        if not results or (#results == 0) then
            show_message("No subtitles found", false)
            return
        end

        select_sub(results[1])
    end
end

--------------------------------------------------------------------------------
-- Function: search for anime. If a search term is provided, use it;
-- otherwise, prompt the user.
--------------------------------------------------------------------------------
local function search(search_term)
    if search_term and search_term ~= "" then
        show_message("Searching for: " .. search_term)
        local url = "https://jimaku.cc/api/entries/search?anime=true&query=" .. urlencode(search_term)
        local results = api(url)

        if not results then
            return
        end

        if #results == 0 then
            show_message("No results found", false)
            return
        end

        if #results == 1 then
            on_anime_selected(results[1])
            return
        end

        -- Multiple anime found – let the user select one.
        local anime_names = {}
        for _, anime in ipairs(results) do
            table.insert(anime_names, anime.name)
        end

        input_select({
            prompt = "Select anime: ",
            items = anime_names,
            submit = function(index)
                on_anime_selected(results[index])
            end
        })
    else
        input_get({
            prompt = "Search for anime: ",
            submit = function(user_input)
                search(user_input)
            end
        })
    end
end

--------------------------------------------------------------------------------
-- Auto-search by filename.
--------------------------------------------------------------------------------
local function auto_search()
    local filename = mp.get_property("filename")
    if not filename then return end
    local sanitized_filename = sanitize(filename)
    local current_anime = extract_title(sanitized_filename)

    mp.set_property("pause", "yes")
    show_message("Auto-searching: " .. current_anime)
    search(current_anime)
end

--------------------------------------------------------------------------------
-- Auto-search using the parent folder name.
--------------------------------------------------------------------------------
local function auto_search_parent_folder()
    local path = mp.get_property("stream-open-filename")
    if not path then return end

    local path_split = {}
    for part in path:gmatch("[^/\\]+") do
        table.insert(path_split, part)
    end

    local folder = (#path_split > 1) and path_split[#path_split - 1] or path_split[#path_split]
    local sanitized_folder = sanitize(folder)
    local current_anime = extract_title(sanitized_folder)

    mp.set_property("pause", "yes")
    show_message("Auto-searching folder: " .. current_anime)
    search(current_anime)
end

--------------------------------------------------------------------------------
-- Key bindings
--------------------------------------------------------------------------------
mp.add_key_binding(MANUAL_SEARCH_KEY, "jimaku-manual-search", function() search() end)
mp.add_key_binding(FILENAME_AUTO_SEARCH_KEY, "jimaku-filename-auto-search", auto_search)
mp.add_key_binding(PARENT_FOLDER_AUTO_SEARCH_KEY, "jimaku-parent-folder-auto-search", auto_search_parent_folder)
