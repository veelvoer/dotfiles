-- ~/.config/nvim/lua/plugins.lua

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- 1. Bestandenboom (De VS Code zijbalk met verborgen bestanden)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = { width = 30 },
        filesystem = { 
          follow_current_file = { enabled = true },
          filtered_items = {
            visible = true,
            show_hidden_count = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          }
        }
      })
    end
  },

  -- 2. Tabbladenbalk bovenaan (Bufferline)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          offsets = {{ filetype = "neo-tree", text = "Verkenner", text_align = "left" }}
        }
      })
    end
  },

  -- 3. Statusbalk onderaan (Lualine)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- 4. Ctrl+P Bestandszoeker (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- 5. Code Highlighting & QML support (Treesitter)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({ 
        "lua", "python", "javascript", "html", "css", "bash", "devicetree", "c", "json" 
      })
      vim.filetype.add({ extension = { qml = "qml" } })
    end
  },

  -- 6. Automatisch sluiten van haakjes en quotes (Auto-pairs)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },

  -- 7. LSP Basis & Mason (Automatische taalservers installeren)
  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },

  -- 8. IntelliSense Autocomplete Engine & Snippets
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- =========================================================================
  -- VISUAL FEATURES TO THE LIMIT
  -- =========================================================================

  -- 9. Git Wijzigings-indicatoren in de kantlijn (Gitsigns)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true
  },

  -- 10. Inspringings-gidslijnen (Indent-blankline)
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    config = true
  },

  -- 11. Opvallende TODO / FIX / NOTE Comments (Todo-comments)
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = true
  }
})
