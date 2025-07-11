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

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "typescript", "go", "kotlin", "lua", "json", "yaml", "javascript", "tsx" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
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

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
    },
    config = function()
      require("Comment").setup()
    end,
  },

  -- Git signs for visual indicators
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
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
    cmd = { "Git", "Gdiff", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
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

  -- Import plugin configurations from lua/plugins/
  { import = "plugins" },
})

-- Key mappings
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

-- Core file operations (lazy-loaded telescope functions)
vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files() end, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', function() require('telescope.builtin').live_grep() end, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', function() require('telescope.builtin').buffers() end, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fr', function() require('telescope.builtin').oldfiles() end, { desc = 'Recent files' })

-- Code navigation (requires LSP)
vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { desc = 'Find references' })
vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end, { desc = 'Go to definition' })
vim.keymap.set('n', '<leader>fs', function() require('telescope.builtin').lsp_document_symbols() end, { desc = 'Document symbols' })

-- Search utilities
vim.keymap.set('n', '<leader>fh', function() require('telescope.builtin').help_tags() end, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fC', function() require('telescope.builtin').commands() end, { desc = 'Commands' })
vim.keymap.set('n', '<leader>fk', function() require('telescope.builtin').keymaps() end, { desc = 'Keymaps' })

-- Git telescope integration
vim.keymap.set('n', '<leader>gb', function() require('telescope.builtin').git_branches() end, { desc = 'Git branches' })
vim.keymap.set('n', '<leader>gc', function() require('telescope.builtin').git_commits() end, { desc = 'Git commits' })
vim.keymap.set('n', '<leader>gf', function() require('telescope.builtin').git_files() end, { desc = 'Git files' })

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
