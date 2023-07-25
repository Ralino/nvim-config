
require("gruvbox").setup({
  contrast = "hard", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {
    CursorLineNr = {bg = "#1d2021"},
    LineNr = {bg = "#1d2021"},
    Folded = {bg = "#1d2021"},
    SignColumn = {bg = "#282828"}
  },
  dim_inactive = false,
  transparent_mode = true,
})
vim.cmd("colorscheme gruvbox")


require("nvim-treesitter.configs").setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "vim", "lua", "cpp", "bash", "python", "cmake", "javascript", "typescript", "qmljs" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = false,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    additional_vim_regex_highlighting = false,
  },
}

-- telescope
local tele_builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-f>', tele_builtin.find_files, {})
vim.keymap.set('n', '<C-p>', tele_builtin.git_files, {})
vim.keymap.set('n', '<leader>*', tele_builtin.grep_string, {})
vim.keymap.set('v', '<leader>*', tele_builtin.grep_string, {})
vim.keymap.set('n', '<leader>/', function()
	tele_builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)


