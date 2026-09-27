vim.opt.compatible = false
vim.opt.termguicolors = true
vim.opt.background = "light"
vim.opt.clipboard = "unnamedplus"
vim.opt.laststatus = 0
vim.opt.showtabline = 0
vim.opt.ruler = false
vim.opt.showmode = false
vim.opt.cmdheight = 0
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.foldcolumn = "0"
vim.opt.statuscolumn = ""
vim.opt.colorcolumn = ""
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.spell = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.shortmess:append("I")
vim.opt.fillchars = { eob = " " }

vim.g.mapleader = " "

pcall(vim.cmd.colorscheme, "peachpuff")
vim.cmd("syntax enable")
vim.cmd("filetype off")

vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<C-v>", '"+p', { noremap = true, silent = true })
vim.keymap.set("i", "<C-v>", "<C-r>+", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.bo.syntax = "markdown"
    vim.cmd("silent! normal! gg")
    vim.cmd("startinsert")
  end,
})
