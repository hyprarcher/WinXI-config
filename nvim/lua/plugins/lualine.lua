return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local p = {
        ink    = "#00060c",
        ground = "#01050a",
        panel  = "#07121f",
        hair   = "#14304a",
        dim    = "#4b6c8a",
        text   = "#c7ddf0",
        bright = "#eaf5ff",
        azure  = "#14a9fd",
        glow   = "#0070c0",
        solar  = "#ffbc49",
        danger = "#ff9299",
        ok     = "#95dbc0",
      }

      local planet_blue_lualine = {
        normal = {
          a = { fg = p.ink, bg = p.azure, gui = "bold" },
          b = { fg = p.bright, bg = p.hair },
          c = { fg = p.text, bg = p.panel },
        },
        insert = {
          a = { fg = p.ink, bg = p.ok, gui = "bold" },
          b = { fg = p.bright, bg = p.hair },
        },
        visual = {
          a = { fg = p.ink, bg = p.solar, gui = "bold" },
          b = { fg = p.bright, bg = p.hair },
        },
        replace = {
          a = { fg = p.ink, bg = p.danger, gui = "bold" },
          b = { fg = p.bright, bg = p.hair },
        },
        command = {
          a = { fg = p.bright, bg = p.glow, gui = "bold" },
          b = { fg = p.bright, bg = p.hair },
        },
        inactive = {
          a = { fg = p.dim, bg = p.ground },
          b = { fg = p.dim, bg = p.ground },
          c = { fg = p.dim, bg = p.ground },
        },
      }

      require("lualine").setup({
        options = {
          theme = planet_blue_lualine,
          icons_enabled = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
          disabled_filetypes = { statusline = { "alpha" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
            },
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
          },
          lualine_c = {
            {
              "filetype",
              colored = true,
              icon_only = true,
              padding = { left = 1, right = 0 },
            },
            { "filename", path = 1 },
          },
          lualine_x = { "encoding", "fileformat" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
}
