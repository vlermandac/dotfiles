return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ltex_plus = {
          filetypes = { "tex" },
          root_markers = {
            ".git",
            ".obsidian",
            ".latexmkrc",
            "latexmkrc",
            ".texlabroot",
            "texlabroot",
            "main.tex",
          },
          settings = {
            ltex = {
              enabled = { "latex", "tex" },
              ["ltex-ls"] = {
                logLevel = "warning",
              },
              language = "en-US",
            },
          },
        },
      },
    },
  },
}
