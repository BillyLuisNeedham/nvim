return {
  "okuuva/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    enabled = true,
    trigger_events = {
      immediate_save = { "BufLeave", "FocusLost" },
      defer_save = { "InsertLeave", "TextChanged" },
      cancel_deferred_save = { "InsertEnter" },
    },
    debounce_delay = 250,
    condition = function(buf)
      local filename = vim.fn.bufname(buf)
      return filename ~= '' and vim.fn.filereadable(filename) == 1
    end,
  },
}
