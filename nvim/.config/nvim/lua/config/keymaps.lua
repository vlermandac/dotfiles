-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keep Vim's default `s` only in Visual mode
pcall(vim.keymap.del, "x", "s")

pcall(vim.keymap.del, "n", "<leader>qq")

vim.keymap.set("n", "<leader>q", function()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.cmd("cclose")
      return
    end
  end
  vim.cmd("copen")
end, { desc = "Quickfix Toggle" })
