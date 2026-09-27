local M = {}

local state = {
  placement = nil,
  autocmds = {},
  seq = 0,
}

local function expand(path)
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
end

local function close()
  state.seq = state.seq + 1

  if state.placement then
    pcall(function()
      state.placement:close()
    end)
    state.placement = nil
  end
end

local function clear_autocmds()
  for _, id in ipairs(state.autocmds) do
    pcall(vim.api.nvim_del_autocmd, id)
  end
  state.autocmds = {}
end

local function bind_dashboard_lifecycle(dashboard)
  clear_autocmds()

  state.autocmds = {
    dashboard.on("UpdatePre", close, dashboard.augroup),
    dashboard.on("Closed", function()
      close()
      clear_autocmds()
    end, dashboard.augroup),
  }
end

local function reserve_text(width, height)
  local line = (" "):rep(width)
  local lines = {}
  for _ = 1, height do
    lines[#lines + 1] = line
  end
  return table.concat(lines, "\n")
end

---Create a snacks.dashboard section that reserves rows, then places a real
---terminal image through snacks.image. Dashboard terminal sections only cache
---terminal text output; Kitty graphics need to go through snacks.image.
---
---This uses Snacks' internal placement API, so small adjustments may be needed
---if snacks.nvim changes its image internals.
---@param opts {path:string, width?:number, height?:number, reserve_width?:number, align?:"left"|"center"|"right", padding?:number}
function M.section(opts)
  opts = opts or {}

  local file = expand(assert(opts.path, "snacks dashboard image path is required"))
  local width = opts.width or 60
  local height = opts.height or 17
  local reserve_width = opts.reserve_width or width
  local align = opts.align or "center"

  if vim.fn.filereadable(file) ~= 1 then
    return {
      text = "Dashboard image not found: " .. file,
      align = "center",
      padding = opts.padding,
    }
  end

  return {
    text = reserve_text(reserve_width, height),
    align = "center",
    padding = opts.padding,
    render = function(dashboard, pos)
      bind_dashboard_lifecycle(dashboard)
      close()

      local seq = state.seq
      vim.schedule(function()
        if seq ~= state.seq then
          return
        end
        if not (dashboard.buf and vim.api.nvim_buf_is_valid(dashboard.buf)) then
          return
        end
        if not (Snacks and Snacks.image and Snacks.image.supports(file)) then
          return
        end

        local offset = align == "center" and math.max(0, math.floor((reserve_width - width) / 2))
          or align == "right" and math.max(0, reserve_width - width)
          or 0
        local row = pos[1]
        local col = pos[2] + offset

        state.placement = Snacks.image.placement.new(dashboard.buf, file, {
          inline = true,
          conceal = true,
          auto_resize = false,
          width = width,
          height = height,
          min_width = width,
          max_width = width,
          min_height = height,
          max_height = height,
          pos = { row, col },
          range = { row, col, row + height - 1, col + width },
        })
      end)
    end,
  }
end

return M
