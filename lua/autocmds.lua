local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ timeout = 200, visual = true })
    end,
    group = highlight_group,
})

-- Restore cursor to file position from previous session
autocmd("BufReadPost", {
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.api.nvim_win_set_cursor(0, mark)
            -- defer centering to after render
            vim.schedule(function()
                vim.cmd("normal! zz")
            end)
        end
    end,
})

-- Open help in vertical split
autocmd("FileType", {
    pattern = "help",
    command = "wincmd L",
})

-- Auto resize splits
autocmd("VimResized", {
    command = "wincmd =",
})

-- Don't continue commenting on newline
local no_auto_comment = augroup("no_auto_comment", {})
autocmd("FileType", {
    group = no_auto_comment,
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Show cursorline only in active window
local active_cursorline = augroup("active_cursorline", { clear = true })
autocmd({ 'WinEnter', 'BufEnter' }, {
    group = active_cursorline,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})
autocmd({ 'WinLeave', 'BufLeave' }, {
    group = active_cursorline,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

-- Highlight symbol under cursor
local lsp_reference_highlight = augroup("LspReferenceHighlight", { clear = true })
autocmd("CursorMoved", {
    group = lsp_reference_highlight,
    desc = "Highlight references under cursor",
    callback = function()
        -- only run if cursor is not in insert mode
        if vim.fn.mode() ~= "i" then
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            local supports_highlight = false
            for _, client in ipairs(clients) do
                if client.server_capabilities.documentHighlightProvider then
                    supports_highlight = true
                    break   -- found a supporting client, no need to check others
                end
            end
            -- proceed only if LSP active and supports this feature
            if supports_highlight then
                vim.lsp.buf.clear_references()
                vim.lsp.buf.document_highlight()
            end
        end
    end,
})
autocmd("CursorMovedI", {
    group = lsp_reference_highlight,
    desc = "Clear highlights when entering insert mode",
    callback = function()
        vim.lsp.buf.clear_references()
    end,
})
