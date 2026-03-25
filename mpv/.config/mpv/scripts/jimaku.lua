local utils = require "mp.utils"
local mpi = require "mp.input"  -- load the mp.input module
local msg = require "mp.msg"    -- load the mp.msg module for logging

-- API Key (Replace with your actual Jimaku API Key)
local API_KEY = "YOUR_API_KEY_GOES_HERE"

-- Config options
local PROMPT_EPISODE = true
local MANUAL_SEARCH_KEY = "h"

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
-- New function: embed the downloaded subtitle into the currently playing video.
-- This version creates a temporary file and then overwrites the current file.
-- Logs from the ffmpeg process are output to the terminal.
--------------------------------------------------------------------------------
local function embed_subtitle(sub_file)
    local input_file = mp.get_property("path")
    if not input_file then
        mp.osd_message("Cannot determine input file.", 2)
        return
    end

    -- Only proceed if the file is an MKV.
    if not input_file:lower():match("%.mkv$") then
        mp.osd_message("Embedding available only for MKV files.", 2)
        return
    end

    -- Create a temporary file name
    local temp_file = input_file .. ".tmp.mkv"

    local command = {
        "ffmpeg",
        "-y",  -- overwrite output without prompting
        "-i", input_file,
        "-i", sub_file,
        -- Map video and audio from the original;
        -- then map the downloaded subtitle (so it becomes first),
        -- then any existing subtitles (if present)
        "-map", "0:v",
        "-map", "0:a",
        "-map", "1",
        "-map", "0:s?",
        "-c", "copy",
        "-metadata:s:s:0", "language=jpn",
        temp_file
    }

    -- Log the ffmpeg command to the terminal.
    msg.info("Executing ffmpeg command: " .. table.concat(command, " "))

    local res = mp.command_native({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
        args = command
    })

    if res.stdout and res.stdout ~= "" then
        msg.info("ffmpeg stdout: " .. res.stdout)
    end
    if res.stderr and res.stderr ~= "" then
        msg.info("ffmpeg stderr: " .. res.stderr)
    end

    if res.error then
        mp.osd_message("Error embedding subtitle: " .. tostring(res.error), 2)
        return
    end

    -- Overwrite the original file with the temporary file.
    local ok, err = os.rename(temp_file, input_file)
    if not ok then
        mp.osd_message("Error overwriting original file: " .. tostring(err), 2)
    else
        mp.osd_message("Subtitle embedded. File overwritten: " .. input_file, 5)
    end
end

--------------------------------------------------------------------------------
-- Function: handle subtitle selection (download, add, and embed).
--------------------------------------------------------------------------------
local function select_sub(sub)
    if not sub then
        show_message("Invalid subtitle selection", false)
        return
    end

    local file = download_sub(sub)
    mp.commandv("sub_add", file)
    show_message("Subtitle downloaded and added: " .. file, false)
    mp.set_property("pause", "no")
    -- Now embed the subtitle into the current file (overwrite it)
    embed_subtitle(file)
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
-- Key binding
--------------------------------------------------------------------------------
mp.add_key_binding(MANUAL_SEARCH_KEY, "jimaku-manual-search", function() search() end)
