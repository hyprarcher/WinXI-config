-- Enables Treesitter syntax highlighting and indentation for your main config/scripting languages
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({})

      -- nvim-treesitter compiles parsers locally. On Windows, tree-sitter passes
      -- the MSVC target triple which Zig rejects; this wrapper maps it to Zig's
      -- bundled GNU target.
      if vim.fn.has("win32") == 1 and vim.fn.executable("zig") == 1 then
        vim.env.CC = vim.fs.joinpath(vim.fn.stdpath("config"), "bin", "zigcc.cmd")
      end

      ts.install({
        "lua",
        "vim",
        "vimdoc",
        "powershell",
        "json",
        "toml",
        "yaml",
        "markdown",
        "markdown_inline",
        "bash",
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
