-- Enable relative line numbers
vim.o.relativenumber = true
vim.o.number = true

-- Clipboard integration for Wayland/Hyprland
vim.o.clipboard = "unnamedplus"

-- Basic editor settings
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.wrap = false
vim.o.swapfile = false
vim.o.backup = false
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.termguicolors = true
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.updatetime = 50

-- Set leader key
vim.g.mapleader = " "

-- Install lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin configuration
require("lazy").setup({
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "gopls", "kotlin_language_server" }
      })
      
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- TypeScript
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
      })
      
      -- Go
      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      })
      
      -- Kotlin
      lspconfig.kotlin_language_server.setup({
        capabilities = capabilities,
      })
    end,
  },

  -- Tokyo Night Theme
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night", -- storm, moon, night, day
        transparent = false,
        terminal_colors = true,
      })
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- Alternative: Catppuccin Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = false,
      })
      -- vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Alternative: Kanagawa Theme
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        transparent = false,
        theme = "wave", -- wave, dragon, lotus
      })
      -- vim.cmd.colorscheme("kanagawa")
    end,
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "typescript", "go", "kotlin", "lua", "json", "yaml" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          relativenumber = true,
        },
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
      }
    },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = "which_key",
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-q>"] = "send_to_qflist",
              ["<C-u>"] = "preview_scrolling_up",
              ["<C-d>"] = "preview_scrolling_down",
            }
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "%.DS_Store"
          },
          layout_config = {
            horizontal = {
              preview_width = 0.6,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" }
          },
          live_grep = {
            additional_args = function(opts)
              return {"--hidden"}
            end
          },
        },
      })
      
      -- Load FZF extension for better fuzzy matching
      require("telescope").load_extension("fzf")
    end,
  },

  -- Git signs for visual indicators
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          
          -- Hunk navigation
          vim.keymap.set('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, buffer = bufnr, desc = 'Next hunk'})
          
          vim.keymap.set('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, buffer = bufnr, desc = 'Previous hunk'})
          
          -- Hunk actions
          vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
          vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
          vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Undo stage hunk' })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
          vim.keymap.set('n', '<leader>hb', gs.blame_line, { buffer = bufnr, desc = 'Blame line' })
          
          -- Stage/reset visual selection
          vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { buffer = bufnr, desc = 'Stage hunk' })
          vim.keymap.set('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { buffer = bufnr, desc = 'Reset hunk' })
        end
      })
    end,
  },

  -- Enhanced Git integration
  {
    "tpope/vim-fugitive",
    config = function()
      -- Git fugitive keybindings
      vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>', { desc = 'Git status' })
      vim.keymap.set('n', '<leader>gd', '<cmd>Git diff<cr>', { desc = 'Git diff' })
      vim.keymap.set('n', '<leader>gl', '<cmd>Git log<cr>', { desc = 'Git log' })
      vim.keymap.set('n', '<leader>gp', '<cmd>Git push<cr>', { desc = 'Git push' })
      vim.keymap.set('n', '<leader>gP', '<cmd>Git pull<cr>', { desc = 'Git pull' })
      vim.keymap.set('n', '<leader>ga', '<cmd>Git add .<cr>', { desc = 'Git add all' })
      vim.keymap.set('n', '<leader>gA', '<cmd>Git add %<cr>', { desc = 'Git add current file' })
      vim.keymap.set('n', '<leader>gC', '<cmd>Git commit<cr>', { desc = 'Git commit' })
      vim.keymap.set('n', '<leader>gB', '<cmd>Git blame<cr>', { desc = 'Git blame' })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
        },
      })
    end,
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({})
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Which-key for keybinding help
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({})
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },
})

-- Key mappings
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

local builtin = require('telescope.builtin')

-- Core file operations
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })

-- Code navigation (requires LSP)
vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = 'Find references' })
vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = 'Go to definition' })
vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })

-- Search utilities
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Commands' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })

-- Git telescope integration
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Git files' })

-- Buffer management
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<cr>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })

-- Window management
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<cr>', { desc = 'Vertical split' })
vim.keymap.set('n', '<leader>wh', '<cmd>split<cr>', { desc = 'Horizontal split' })
vim.keymap.set('n', '<leader>wc', '<cmd>close<cr>', { desc = 'Close window' })

-- Quick save
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>x', '<cmd>x<cr>', { desc = 'Save and quit' })
