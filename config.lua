--[[

THIS IS MY LUNARVIM CONFIG FOR WINDOWS
DRAG AND DROP THIS INTO %localappdata%/lvim
LAUNCH LUNARVIM AND LET IT INSTALL THE PLUGINS
THIS FILE IS FREE FOR DISTRIBUTION AND MODIFICATION
AS LONG AS CREDIT IS ATTRIBUTED TO THE DUE PEOPLE

lunarvim: for the client and default settings
https://www.lunarvim.org/
install lunarvim: https://www.lunarvim.org/docs/installation

AtTheZenith: for modification of the config file
https://github.com/AtTheZenith
get config file: https://github.com/AtTheZenith/AtTheZenith/config.lua

Read the docs: https://www.lunarvim.org/docs/configuration
Example configs: https://github.com/LunarVim/starter.lvim
Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
Forum: https://www.reddit.com/r/lunarvim/
Discord: https://discord.com/invite/Xb9B4Ny

]]--

--[[

  DEFAULT SETTINGS

]]--


-- Default Shell
vim.opt.shell = "pwsh.exe"
vim.opt.shellcmdflag =
"-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.cmd [[
		let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		set shellquote= shellxquote=
  ]]

-- Clipboard Manager
vim.g.clipboard = {
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "win32yank.exe -o --lf",
    ["*"] = "win32yank.exe -o --lf",
  },
}


--[[

BINDS AND SETTINGS
VISUAL PLUGINS
THEMES
FUNCTIONALITY PLUGINS

]] --

-- Set buffer navigation
lvim.keys.normal_mode["n"] = ":bnext<CR>"
lvim.keys.normal_mode["<C-n>"] = ":bprevious<CR>"

-- Set Spectre start key
lvim.builtin.which_key.mappings.s["s"] = { ":Spectre<CR>", "Spectre (Find/Replace)" }

-- Set Terminal keybind and remove a keybind for balance
lvim.builtin.which_key.mappings.f = nil
lvim.builtin.which_key.mappings.t = { ":ToggleTerm<CR>", "Open Terminal (Fullscreen)" }

-- Set transparent window
-- lvim.transparent_window = true

-- Theme
lvim.colorscheme = "kanagawa-wave"

-- Status-bar {{{{

lvim.builtin.lualine.style = "default"

local clients_lsp = function()
	local clients = vim.lsp.get_clients()
	if next(clients) == nil then
		return ""
	end

  local c = {}
	for _, client in pairs(clients) do
		table.insert(c, client.name)
	end
	return "  LSP: " .. table.concat(c, " | ")
end

lvim.builtin.lualine.options = {
	theme = require('lualine.themes.iceberg_dark'),
	component_separators = ">",
	section_separators = { left = "", right = "" },
	disabled_filetypes = { "alpha", "Outline" },
}

lvim.builtin.lualine.sections = {
	lualine_a = {
		{
      "mode",
      separator = { left = "", right = "" },
      icon = "",
      padding = { left = 2, right = 1 }
    },
	},
	lualine_b = {
		{
			"filetype",
			icon_only = true,
			padding = { left = 2, right = 0 },
		},
		{
      "filename",
      padding = { left = 1, right = 1}
    },
	},
	lualine_c = {
		{
			"branch",
			icon = "",
		},
		{
  		"diff",
			symbols = { added = " ", modified = " ", removed = " " },
			colored = false,
		},
	},
	lualine_x = {
		{
			"diagnostics",
			symbols = { error = " ", warn = " ", info = " ", hint = " " },
			update_in_insert = true,
		},
	},
	lualine_y = { clients_lsp },
	lualine_z = {
		{
      "location",
      separator = { left = " ", right = "" },
      icon = "",
      padding = { left = 1, right = 2 }
    },
	},
}

lvim.builtin.lualine.inactive_sections = {
	lualine_a = { "filename" },
	lualine_b = {},
	lualine_c = {},
	lualine_x = {},
	lualine_y = {},
	lualine_z = { "location" },
}

lvim.builtin.lualine.extensions = { "toggleterm", "trouble", "nvim-tree", "fugitive" }

-- }}}}

lvim.plugins = {
  -- Codemap
  {
    "echasnovski/mini.map",
    branch = "stable",
    config = function()
      require('mini.map').setup()
      local map = require('mini.map')
      map.setup({
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic({
            error = 'DiagnosticFloatingError',
            warn  = 'DiagnosticFloatingWarn',
            info  = 'DiagnosticFloatingInfo',
            hint  = 'DiagnosticFloatingHint',
          }),
        },
        symbols = {
          encode = map.gen_encode_symbols.dot('4x2'),
        },
        window = {
          side = 'right',
          width = 20, -- set to 1 for a pure scrollbar :)
          winblend = 15,
          show_integration_count = false,
        },
      })
    end
  },

  -- Smooth Scrolling
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
    require('neoscroll').setup({
      -- All these keys will be mapped to their corresponding default scrolling animation
      mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb'},
      hide_cursor = true,          -- Hide cursor while scrolling
      stop_eof = true,             -- Stop at <EOF> when scrolling downwards
      use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
      respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
      easing_function = nil,       -- Default easing function
      pre_hook = nil,              -- Function to run before the scrolling animation starts
      post_hook = nil,             -- Function to run after the scrolling animation ends
      })
    end
  },

  -- Search-and-Replace
  {
    "nvim-pack/nvim-spectre",
    event = "BufRead",
    config = function()
      require("spectre").setup()
    end,
  },

  -- Cursor Solution
  {
    "ggandor/leap.nvim",
    name = "leap",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- Provides speedy color highligting
  {
    "norcalli/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup({"lua", "css", "scss", "html", "javascript" }, {
            RGB = true, -- #RGB hex codes
            RRGGBB = true, -- #RRGGBB hex codes
            RRGGBBAA = true, -- #RRGGBBAA hex codes
            rgb_fn = true, -- CSS rgb() and rgba() functions
            hsl_fn = true, -- CSS hsl() and hsla() functions
            css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
            css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
            })
    end,
  },

  -- Git Wrapper
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit"
    },
    ft = {"fugitive"}
  },

  -- Type hints when you type
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require"lsp_signature".on_attach() end,
  },

  -- LSP compatibility layer for color schemes that don't support the NeoVim 0.5 LSP Client
  {
    "folke/lsp-colors.nvim",
    event = "BufRead",
  },

  -- Themes
  { "catppuccin/nvim" },
  { "slugbyte/lackluster.nvim" },
  { "folke/tokyonight.nvim" },
  { "arcticicestudio/nord-vim" },
  { "sontungexpt/witch" },
  { "comfysage/evergarden" },
  { "kyazdani42/blue-moon" },
  { "ellisonleao/gruvbox.nvim" },
  { "EdenEast/nightfox.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  { "eldritch-theme/eldritch.nvim" },
--{ "Mofiqul/adawaita.nvim" },
--{ "Mofiqul/dracula.nvim" },
  { "yorumicolors/yorumi.nvim" },
  { "cocopon/iceberg.vim" },
  { "maxmx03/solarized.nvim" },
  { "maxmx03/fluoromachine.nvim" },
  { "nordtheme/vim" },
  { "oxfist/night-owl.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "nuvic/flexoki-nvim" },
  { "bluz71/vim-nightfly-colors" },


  -- Completion Engines
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  {
    "tzachar/cmp-tabnine",
    build = "./install.ps1",
    dependencies = "hrsh7th/nvim-cmp",
    event = "InsertEnter",
  },
}

-- Auto-Start Scrollbar
lvim.autocommands = {
  {
    {"BufEnter", "Filetype"},
    {
      desc = "Open mini.map and exclude some filetypes",
      pattern = { "*" },
      callback = function()
        local exclude_ft = {
          "qf",
          "NvimTree",
          "toggleterm",
          "TelescopePrompt",
          "alpha",
          "netrw",
        }

        local map = require('mini.map')
        if vim.tbl_contains(exclude_ft, vim.o.filetype) then
          vim.b.minimap_disable = true
          map.close()
        elseif vim.o.buftype == "" then
          map.open()
        end
      end,
    },
  },
}
