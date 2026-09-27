-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      image = {
        enabled = true,
        force = true,
        -- your image configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      dashboard = {
        sections = {
          require("config.snacks-dashboard-image").section({
            path = vim.env.SNACKS_DASHBOARD_IMAGE or "~/Common/Pictures/bocchi.jpg",
            width = 60,
            height = 17,
            align = "center",
            padding = 1,
          }),
          {
            { section = "keys", gap = 1, padding = 1 },
            { section = "startup" },
          },
        },
      },
    },
  },
}
