-- ~/.config/nvim/lua/theme.lua

local colors = {
  -- We halen de harde achtergrondkleur hier weg zodat de terminal bepaalt!
  fg       = "#E8F8FA", -- Light Mist Highlights (volgt jouw Kitty foreground)
  pill_bg  = "#12424C", -- Mark 3 / QuickShell bg
  accent   = "#3FD0DC", -- Bright Atmosphere / Cursor
  teal_glow= "#2BB1BB", -- Cyan Glow
  dim_teal = "#186A73", -- Midtone Ridge Shadows
  error_red= "#F38BA8", -- Warning Accent
  git_add  = "#10B981", -- Subtiel groen voor Git add
  git_mod  = "#F59E0B", -- Subtiel oranje voor Git mod
}

-- TRANSPARANTIE & TERMINAL MATCHING PROTOCOL
-- Door guibg=NONE te gebruiken, pakt Neovim exact de kleur en transparantie van Kitty!
vim.cmd("highlight Normal guibg=NONE guifg=" .. colors.fg)
vim.cmd("highlight NonText guibg=NONE guifg=" .. colors.dim_teal)
vim.cmd("highlight SignColumn guibg=NONE")
vim.cmd("highlight StatusLine guibg=NONE")
vim.cmd("highlight StatusLineNC guibg=NONE")

-- Geef de zijbalk een heel subtiel contrast ten opzichte van de terminal achtergrond
vim.cmd("highlight NeoTreeNormal guibg=" .. colors.pill_bg .. " guifg=" .. colors.fg)
vim.cmd("highlight NeoTreeNormalNC guibg=" .. colors.pill_bg .. " guifg=" .. colors.fg)
vim.cmd("highlight CursorLine guibg=" .. colors.pill_bg)

-- Geef actieve elementen en randen jouw unieke Mountain Horizon Teal glow
vim.cmd("highlight WinSeparator guibg=NONE guifg=" .. colors.dim_teal)
vim.cmd("highlight LineNr guibg=NONE guifg=" .. colors.dim_teal)
vim.cmd("highlight CursorLineNr guibg=NONE guifg=" .. colors.accent .. " gui=bold")

-- =========================================================================
-- VISUAL INDICATORS HIGH-LIGHTING
-- =========================================================================

-- Inspringingslijnen (Indent Guides)
vim.cmd("highlight IblIndent guifg=" .. colors.pill_bg .. " gui=nocombine")
vim.cmd("highlight IblScope guifg=" .. colors.dim_teal .. " gui=nocombine")

-- Git kantlijn indicatoren (Gitsigns)
vim.cmd("highlight GitSignsAdd guifg=" .. colors.git_add .. " guibg=NONE")
vim.cmd("highlight GitSignsChange guifg=" .. colors.git_mod .. " guibg=NONE")
vim.cmd("highlight GitSignsDelete guifg=" .. colors.error_red .. " guibg=NONE")

-- Lualine (onderbalk) styling met jouw kleuren
require('lualine').setup({
  options = {
    theme = {
      normal = {
        a = { bg = colors.accent, fg = "#0D2C34", bold = true },
        b = { bg = colors.pill_bg, fg = colors.fg },
        c = { bg = "NONE", fg = colors.fg }, -- Onderbalk vloeit mooi over
      },
      insert = {
        a = { bg = colors.teal_glow, fg = "#0D2C34", bold = true },
      },
      visual = {
        a = { bg = colors.dim_teal, fg = colors.fg, bold = true },
      },
    },
    component_separators = '|',
    section_separators = '',
  }
})

-- Bufferline (tabbladenbalk) styling
require('bufferline').setup({
  options = {
    highlights = {
      fill = { bg = "NONE" }, -- Tabbladenbalk achtergrond matcht terminal
      background = { bg = colors.pill_bg, fg = colors.dim_teal },
      buffer_selected = { bg = "NONE", fg = colors.accent, bold = true },
      separator = { fg = colors.pill_bg },
    }
  }
})
