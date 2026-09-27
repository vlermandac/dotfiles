-- Minimal Neovim profile for Kitty's scrollback pager.
-- Kitty supplies ANSI-formatted scrollback on stdin; no user plugins are loaded.

vim.g.mapleader = " "

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.showtabline = 0
vim.opt.laststatus = 3
vim.opt.statusline = "  Kitty scrollback%=%l/%L  "
vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.ruler = false

vim.opt.wrap = false
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 5
vim.opt.cursorline = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false
vim.opt.shadafile = "NONE"
vim.opt.fillchars = { eob = " " }

local colors_file = vim.fn.expand("~/.cache/wal/colors-wal.vim")
if vim.fn.filereadable(colors_file) == 1 then
  vim.cmd.source(colors_file)

  local function color(name, fallback)
    return vim.g[name] or fallback
  end

  local background = color("background", "#101418")
  local foreground = color("foreground", "#e0e2e8")
  local primary = color("color4", "#98ccf9")
  local surface = color("color8", "#42474e")
  local selection = color("color12", "#044b71")
  local search = color("color3", "#d1bfe7")

  for index = 0, 15 do
    vim.g["terminal_color_" .. index] = color("color" .. index, foreground)
  end

  vim.api.nvim_set_hl(0, "Normal", { fg = foreground, bg = background })
  vim.api.nvim_set_hl(0, "NormalNC", { fg = foreground, bg = background })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = background, bg = background })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = surface })
  vim.api.nvim_set_hl(0, "Visual", { fg = foreground, bg = selection })
  vim.api.nvim_set_hl(0, "Search", { fg = background, bg = search, bold = true })
  vim.api.nvim_set_hl(0, "IncSearch", { fg = background, bg = primary, bold = true })
  vim.api.nvim_set_hl(0, "CurSearch", { fg = background, bg = primary, bold = true })
  vim.api.nvim_set_hl(0, "StatusLine", { fg = background, bg = primary, bold = true })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = foreground, bg = surface })
else
  vim.cmd.colorscheme("habamax")
end

vim.keymap.set("n", "q", "<cmd>qa!<cr>", {
  silent = true,
  desc = "Close Kitty scrollback",
})

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.bo.buflisted = false
    vim.bo.swapfile = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})
