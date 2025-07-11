-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Quickfix navigation for chained grep workflow
vim.keymap.set("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open Quickfix List" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close Quickfix List" })
vim.keymap.set("n", "<leader>qn", "<cmd>cnext<cr>", { desc = "Next Quickfix Item" })
vim.keymap.set("n", "<leader>qp", "<cmd>cprev<cr>", { desc = "Previous Quickfix Item" })

-- Jump to first/last quickfix item
vim.keymap.set("n", "<leader>qf", "<cmd>cfirst<cr>", { desc = "First Quickfix Item" })
vim.keymap.set("n", "<leader>ql", "<cmd>clast<cr>", { desc = "Last Quickfix Item" })
