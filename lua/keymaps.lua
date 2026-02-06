local map = vim.keymap.set
local s = { silent = true }
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "

map("n", "<space>", "<Nop>")

map("n", "<C-d>", "<C-d>zz") -- Scroll down and center the cursor
map("n", "<C-u>", "<C-u>zz") -- Scroll up and center the cursor
map("n", "<Leader>]", "<cmd>bn<CR>") -- Next buffer
map("n", "<Leader>[", "<cmd>bp<CR>") -- Previous buffer

map("n", "<Leader>fo", "<cmd>lua vim.lsp.buf.format()<CR>", s) -- Format the current buffer using LSP
map("t", "<Esc>", "<C-\\><C-N>") -- Exit terminal mode

-- Global LSP defaults: gra gri grn grr grt i_CTRL-S v_an v_in
map("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts) -- Go to definition

-- Fuzzy picker
map("n", "<leader><Leader>", '<cmd>FzfLua files<CR>')
map("n", "<leader>fb", '<cmd>FzfLua buffers<CR>')
map("n", "<leader>fg", '<cmd>FzfLua live_grep<CR>')

-- Netrw
map("n", "<Leader>b", "<cmd>Lex<CR>")
