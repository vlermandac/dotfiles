-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function make_transparent()
  local transparent_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "StatusColumn",
    "EndOfBuffer",
    "LineNr",
    "CursorLineNr",
    "CursorLine",
    "CursorColumn",
    "ColorColumn",
    "FoldColumn",
    "Folded",
    "WinBar",
    "WinBarNC",
    "TabLine",
    "TabLineFill",
    "WinSeparator",
    "Pmenu",
    "PmenuSel",
    "PmenuSbar",
    "PmenuThumb",
    "Search",
    "IncSearch",
    "QuickFixLine",
  }

  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end

  local ok_palette, palette = pcall(require, "neopywal.lib.palette")
  local ok_color, color = pcall(require, "neopywal.utils.color")
  local bar_bg = "#22262a"
  local bar_bg_nc = "#1e2226"
  local line_bg = "#2a3035"
  local line_fg = "#e0e2e8"
  local visual_bg = "#30363c"
  if ok_palette and ok_color then
    local C = palette.get()
    bar_bg = color.blend(C.foreground, C.background, 0.14)
    bar_bg_nc = color.blend(C.foreground, C.background, 0.08)
    line_bg = color.blend(C.foreground, C.background, 0.18)
    visual_bg = color.blend(C.foreground, C.background, 0.24)
  end

  vim.api.nvim_set_hl(0, "CursorLine", { bg = line_bg })
  vim.api.nvim_set_hl(0, "CursorLineNr", { bg = line_bg, fg = line_fg })
  vim.api.nvim_set_hl(0, "Visual", { bg = visual_bg })
  vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bg = line_bg, fg = line_fg })
  vim.api.nvim_set_hl(0, "SnacksPickerPreviewCursorLine", { bg = line_bg, fg = line_fg })
  vim.api.nvim_set_hl(0, "MiniFilesCursorLine", { bg = line_bg })
  vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = line_bg })
  vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = line_bg })
  vim.api.nvim_set_hl(0, "StatusLine", { bg = bar_bg, fg = "#e0e2e8" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = bar_bg_nc, fg = "#c7cbd1" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = make_transparent,
})

make_transparent()
