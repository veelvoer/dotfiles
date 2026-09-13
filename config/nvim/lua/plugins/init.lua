return {
  {
    "miikanissi/modus-themes.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme modus_vivendi")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    version = "*",
    config = function()
      require("bufferline").setup({
        options = {
          offsets = { { filetype = "neo-tree", text = "File Explorer", text_align = "left" } },
        }
      })
      vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>")
      vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>")
      vim.keymap.set("n", "<leader>x", "<cmd>bdelete<cr>")
    end,
  },
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
        window = { width = 30 }
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle left<cr>")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({ options = { theme = "auto" } })
    end,
  }
}
