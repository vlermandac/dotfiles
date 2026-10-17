return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura_simple"
      vim.g.vimtex_view_automatic = 0
      vim.g.vimtex_callback_progpath = vim.fn.expand("~/.local/bin/nvim-vimtex-inverse")
      -- Flathub's current build has no SyncTeX library. Opening/reloading works;
      -- disable unsupported source-jump flags instead of breaking PDF viewing.
      vim.g.vimtex_view_zathura_use_synctex = 0
      vim.g.vimtex_view_zathura_check_libsynctex = 0
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0

      vim.g.vimtex_compiler_latexmk = {
        aux_dir = "build",
        out_dir = "build",
        options = {
          "-verbose",
          "-lualatex",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-file-line-error",
        },
      }
    end,
    keys = {
      { "<leader>lc", "<cmd>VimtexCompile<cr>", desc = "LaTeX Compile" },
      { "<leader>lv", "<cmd>VimtexView<cr>", desc = "LaTeX View" },
      { "<leader>le", "<cmd>VimtexErrors<cr>", desc = "LaTeX Errors" },
      { "<leader>lk", "<cmd>VimtexStop<cr>", desc = "LaTeX Stop" },
      { "<leader>lC", "<cmd>VimtexClean<cr>", desc = "LaTeX Clean" },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    ft = "tex",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      ls.config.setup({
        enable_autosnippets = true,
        update_events = "TextChanged,TextChangedI",
      })

      ls.add_snippets("tex", {
        s({ trig = "mk", snippetType = "autosnippet", wordTrig = true }, {
          t("$"),
          i(1),
          t("$"),
        }),
        s({ trig = "dm", snippetType = "autosnippet", wordTrig = true }, {
          t({ "$$", "" }),
          i(1),
          t({ "", "$$" }),
        }),
      })
    end,
  },
}
