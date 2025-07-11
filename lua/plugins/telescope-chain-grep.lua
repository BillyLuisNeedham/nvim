return {
  "nvim-telescope/telescope.nvim",
  dependencies = { 
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make"
    }
  },
  keys = {
    -- View quickfix in telescope
    { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "View Quickfix List" },
    -- Chain grep - search within quickfix results
    { "<leader>fG", function()
      local qflist = vim.fn.getqflist()
      local files = {}
      local seen = {}
      for _, item in ipairs(qflist) do
        local filename = vim.fn.bufname(item.bufnr)
        if filename ~= "" and not seen[filename] then
          table.insert(files, filename)
          seen[filename] = true
        end
      end
      
      if #files == 0 then
        vim.notify("No files in quickfix list. Run a grep search first and send results to quickfix with <C-q>", vim.log.levels.WARN)
        return
      end
      
      require("telescope.builtin").live_grep({
        search_dirs = files,
        prompt_title = "Live Grep in Quickfix Results (" .. #files .. " files)"
      })
    end, desc = "Chain Grep (search in quickfix)" },
    -- Alternative: search within selected files from previous telescope session
    { "<leader>fc", function()
      -- Get the most recent telescope picker
      local telescope_state = require("telescope.state")
      local last_picker = telescope_state.get_global_key("last_picker")
      if not last_picker then
        vim.notify("No previous Telescope session found", vim.log.levels.WARN)
        return
      end
      
      -- Get selected entries from the last picker
      local selections = last_picker:get_multi_selection()
      if #selections == 0 then
        vim.notify("No files selected in previous search. Use <Tab> to select files, then try again.", vim.log.levels.WARN)
        return
      end
      
      local files = {}
      for _, selection in ipairs(selections) do
        if selection.filename then
          table.insert(files, selection.filename)
        elseif selection.path then
          table.insert(files, selection.path)
        end
      end
      
      if #files > 0 then
        require("telescope.builtin").live_grep({
          search_dirs = files,
          prompt_title = "Chain Grep in Selected Files (" .. #files .. " files)"
        })
      else
        vim.notify("No valid files found in selection", vim.log.levels.WARN)
      end
    end, desc = "Chain Grep (search in selected files)" },
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension("fzf")
  end,
  opts = {
    defaults = {
      mappings = {
        i = {
          ["<C-h>"] = "which_key",
          ["<C-j>"] = "move_selection_next", 
          ["<C-k>"] = "move_selection_previous",
          ["<C-u>"] = "preview_scrolling_up",
          ["<C-d>"] = "preview_scrolling_down",
          -- Multi-select capability for chaining
          ["<Tab>"] = "toggle_selection",
          ["<S-Tab>"] = "toggle_selection",
        },
        n = {
          ["<Tab>"] = "toggle_selection",
          ["<S-Tab>"] = "toggle_selection",
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
      quickfix = {
        theme = "ivy",
      },
    },
  },
} 