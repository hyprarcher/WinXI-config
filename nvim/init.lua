-- LEADER KEY ASSIGNMENT
-- =====================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- =====================

-- Other Useful Options
-- =====================
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 250
opt.splitbelow = true
opt.splitright = true
opt.undofile = true
-- =====================

-- Requires
-- =====================
require("config.lazy")
require("config.keymaps")
-- =====================
