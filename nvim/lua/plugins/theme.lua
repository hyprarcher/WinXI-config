return {
  {
    dir = vim.fn.stdpath("config"),
    name = "planet_blue_theme",
    lazy = false,
    priority = 1000,
    config = function()
      local p = {
        ink    = "#00060c",
        ground = "#01050a",
        panel  = "#07121f",
        hair   = "#14304a",
        dim    = "#4b6c8a",
        text   = "#c7ddf0",
        bright = "#eaf5ff",
        ice    = "#ffffff",
        azure  = "#14a9fd",
        glow   = "#0070c0",
        deep   = "#004080",
        solar  = "#ffbc49",
        danger = "#ff9299",
        ok     = "#95dbc0",
      }

      vim.cmd("hi clear")
      if vim.fn.exists("syntax_on") == 1 then
        vim.cmd("syntax reset")
      end
      vim.g.colors_name = "planet_blue"

      local set = function(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
      end

      set("Normal", { fg = p.text, bg = "NONE" })
      set("NormalNC", { fg = p.text, bg = "NONE" })
      set("NormalFloat", { fg = p.text, bg = p.panel })
      set("FloatBorder", { fg = p.hair, bg = p.panel })
      set("CursorLine", { bg = p.panel })
      set("CursorLineNr", { fg = p.azure, bold = true })
      set("LineNr", { fg = p.dim })
      set("SignColumn", { bg = "NONE" })
      set("VertSplit", { fg = p.hair })
      set("WinSeparator", { fg = p.hair })
      set("StatusLine", { fg = p.bright, bg = p.panel })
      set("StatusLineNC", { fg = p.dim, bg = p.ground })
      set("Visual", { fg = p.ice, bg = p.deep })
      set("Search", { fg = p.ink, bg = p.solar })
      set("IncSearch", { fg = p.ink, bg = p.azure })
      set("Pmenu", { fg = p.text, bg = p.panel })
      set("PmenuSel", { fg = p.ink, bg = p.azure, bold = true })
      set("PmenuSbar", { bg = p.ground })
      set("PmenuThumb", { bg = p.hair })

      set("Comment", { fg = p.dim, italic = true })
      set("Constant", { fg = p.solar })
      set("String", { fg = p.ok })
      set("Identifier", { fg = p.bright })
      set("Function", { fg = p.azure })
      set("Statement", { fg = p.glow, bold = true })
      set("Keyword", { fg = p.azure })
      set("Type", { fg = p.solar })
      set("DiagnosticError", { fg = p.danger })
      set("DiagnosticWarn", { fg = p.solar })
      set("DiagnosticInfo", { fg = p.azure })
      set("DiagnosticHint", { fg = p.dim })

      -- Noice floating cmdline popup (planet_blue)
      set("NoiceCmdlinePopup", { fg = p.text, bg = p.panel })
      set("NoiceCmdlinePopupBorder", { fg = p.azure, bg = p.panel })
      set("NoiceCmdlinePopupTitle", { fg = p.ink, bg = p.azure, bold = true })
      set("NoiceCmdlineIcon", { fg = p.azure })
      set("NoiceCmdlinePopupBorderSearch", { fg = p.solar, bg = p.panel })
      set("NoiceCmdlineIconSearch", { fg = p.solar })
      set("NoicePopupmenu", { fg = p.text, bg = p.panel })
      set("NoicePopupmenuBorder", { fg = p.hair, bg = p.panel })
      set("NoicePopupmenuSelected", { fg = p.ink, bg = p.azure, bold = true })
      set("NoiceMini", { fg = p.text, bg = p.panel })

      -- WhichKey floating card (LazyVim layout in planet_blue)
      set("WhichKeyNormal", { fg = p.text, bg = p.panel })
      set("WhichKeyBorder", { fg = p.hair, bg = p.panel })
      set("WhichKeyTitle", { fg = p.ink, bg = p.azure, bold = true })
      set("WhichKey", { fg = p.azure, bold = true })
      set("WhichKeyGroup", { fg = p.solar, bold = true })
      set("WhichKeySeparator", { fg = p.dim })
      set("WhichKeyDesc", { fg = p.bright })
      set("WhichKeyValue", { fg = p.dim })
    end,
  },
}
