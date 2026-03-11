-- ========================================================================== --
-- ==                           1. OPCIONES BÁSICAS                        == --
-- ========================================================================== --
vim.g.mapleader = " "           -- La tecla líder es el Espacio
vim.opt.number = true           -- Números de línea
vim.opt.relativenumber = true   -- Números relativos
vim.opt.mouse = 'a'             -- Ratón habilitado
vim.opt.tabstop = 4             -- Tabulación de 4 espacios
vim.opt.shiftwidth = 4
vim.opt.expandtab = true        -- Espacios en vez de tabs
vim.opt.termguicolors = true    -- Colores reales
vim.opt.ignorecase = true       -- Búsqueda inteligente
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"

-- ========================================================================== --
-- ==                        2. DESCARGA DEL GESTOR                        == --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)



require("lazy").setup({
  { 
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end
  },

  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    config = function()
      -- El truco del ingeniero: pcall intenta cargar el módulo sin romper nada
      local ok, treesitter = pcall(require, "nvim-treesitter.configs")
      if not ok then return end -- Si no está instalado aún, salimos sin error
      
      treesitter.setup({
        ensure_installed = { "c", "python", "lua", "markdown" },
        highlight = { enable = true },
      })
    end
  },


  -- LSP (El cerebro conectado a Arch)
  { 
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/nvim-cmp",         
      "hrsh7th/cmp-nvim-lsp",     
      "L3MON4D3/LuaSnip",         
    },
    config = function()
      local cmp = require('cmp')
      
      -- 1. Configuración del Autocompletado (Esto sigue igual)
      cmp.setup({
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
        }),
        sources = { { name = 'nvim_lsp' } }
      })

      -- 2. CONFIGURACIÓN MODERNA (Neovim 0.11+)
      -- Definimos las capacidades (comunicación editor <-> lenguaje)
      local caps = require('cmp_nvim_lsp').default_capabilities()

      -- En lugar de require('lspconfig').clangd.setup, usamos la vía nativa:
      local servers = { "clangd", "pyright" }

      for _, lsp in ipairs(servers) do
        -- Registramos la configuración del servidor
        vim.lsp.config(lsp, { capabilities = caps })
        -- Lo activamos
        vim.lsp.enable(lsp)
      end
    end
  },

  { 
    "nvim-telescope/telescope.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {}) -- Espacio + ff (find files)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})  -- Espacio + fg (grep texto)
    end
  },

  { 
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {}) -- Espacio + e (explorer)
    end
  },


  { 
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup({ options = { theme = 'catppuccin' } })
    end
  },

  { "lewis6991/gitsigns.nvim", config = true },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- ATAJOS DE HARPOON
      -- 1. Menú visual para ver qué tienes "clavado"
      vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      
      -- 2. "Clavar" el archivo actual a la lista
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)

      -- 3. Saltar a los archivos (Navegación ultra rápida)
      vim.keymap.set("n", "<A-1>", function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<A-2>", function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<A-3>", function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<A-4>", function() harpoon:list():select(4) end)
    end
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
    ft = { "markdown" }, -- Solo se carga cuando abres un .md (eficiencia Arch)
  },

})

-- Al pulsar 'K' sobre una función, te enseña la documentación (LSP)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})

-- Al pulsar 'gd', salta a la definición de la función (Go to Definition)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})

-- Esto es lo que configuramos en tu init.lua
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {})

-- Moverse entre splits con Ctrl + dirección (sin pulsar 'w')
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Mover a la izquierda' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Mover abajo' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Mover arriba' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Mover a la derecha' })
