-- ~/.config/nvim/init.lua

-- Basisinstellingen (VSCodium gedrag)
vim.g.mapleader = " " 
vim.opt.number = true 
vim.opt.relativenumber = false 
vim.opt.mouse = "a" 
vim.opt.clipboard = "unnamedplus" 
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true 

-- Sneltoetsen (Mappen, Bestanden & Tabbladen)
local keymap = vim.keymap.set

keymap("n", "<C-b>", ":Neotree toggle left<CR>", { silent = true, desc = "Zijbalk mappen" })
keymap("n", "<C-p>", ":Telescope find_files<CR>", { silent = true, desc = "Zoek bestanden" })
keymap("n", "<TAB>", ":bnext<CR>", { silent = true, desc = "Volgend tabblad" })
keymap("n", "<S-TAB>", ":bprevious<CR>", { silent = true, desc = "Vorig tabblad" })
keymap("n", "<C-w>", ":bdelete<CR>", { silent = true, desc = "Sluit tabblad" })

-- Laad Plug-ins & Thema basissen
require("plugins")
require("theme")

-----------------------------------------------------------------
-- INTERN: LSP & INTELLISENSE CONFIGURATIE (MAX OUT)
-----------------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
    -- Automatische taalservers voor jouw talen (inclusief qmlls voor Quickshell/QML)
    ensure_installed = { "lua_ls", "pyright", "ts_ls", "bashls", "qmlls" }
})

-- Koppel LSP aan Neovim autocomplete mogelijkheden
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Activeer de taalservers volgens de NIEUWE Neovim 0.11+ API standaarden
local servers = { "lua_ls", "pyright", "ts_ls", "bashls", "qmlls" }
for _, server in ipairs(servers) do
    vim.lsp.config(server, {
        capabilities = capabilities,
    })
    vim.lsp.enable(server)
end

-- VS Code-achtige LSP Sneltoetsen (foutmeldingen bekijken, definities zoeken)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        keymap('n', 'gd', vim.lsp.buf.definition, opts) -- 'Go to Definition' (zoals F12)
        keymap('n', 'K', vim.lsp.buf.hover, opts)       -- Toon documentatie popup
        keymap('n', '<leader>rn', vim.lsp.buf.rename, opts) -- Slim hernoemen overal
        keymap({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- Code Fixes / Actions
    end,
})

-- IntelliSense Pop-up Menu Gedrag (Ctrl+Spatie of typen om te openen, Tab/Enter om te kiezen)
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(), -- Handmatig pop-up triggeren
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter om te voltooien
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim-lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    })
})

