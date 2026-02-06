return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = {
        '.emmyrc.json',
        '.luarc.json',
        '.luarc.jsonc',
        '.luacheckrc',
        '.stylua.toml',
        'stylua.toml',
        'selene.toml',
        'selene.yml',
        '.git',
    },
    -- Add nvim rtp as library so we don't get undefined global vim error
    settings = {
        Lua = {
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
            }
        }
    }
}
