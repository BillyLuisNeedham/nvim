# Chain Grep Idiot's Guide

This file explains the two different ways to "chain grep" configured in this Neovim setup. Think of it as searching, and then searching *within* your search results to narrow things down.

---

### Method 1: Searching Within Search Results (Quickfix)

This is the `<leader>fG` mapping.

1.  **Do a normal search.**
    Use Telescope's `live_grep` (or any other search tool) to find something across your entire project.

2.  **Send the results to the "Quickfix List".**
    While in the Telescope search results, instead of just opening a file, you press `<C-q>` (Control + q). This acts like sending all the files from your search results to a temporary list.

3.  **Search within that list.**
    Now, press `<leader>fG`. This runs a *new* search, but instead of looking through your whole project again, it **only searches inside the files from your Step 2 results**.

**In short:** You do a broad search, dump the results into a list, then do another, more specific search on just that list.

---

### Method 2: Searching Within Selected Files

This is the `<leader>fc` mapping.

1.  **Find and select files.**
    Open Telescope with `find_files` or `live_grep`. As you see files you're interested in, press the `<Tab>` key to select them. You can select as many as you want.

2.  **Search within your selection.**
    After you've selected a handful of files, close Telescope and press `<leader>fc`. This will start a *new* `live_grep` search that **only looks at the files you selected with `<Tab>`**.

**In short:** You hand-pick a few files, and then run a search that is restricted to only those files.

### Why is this useful?

It lets you drill down to find what you're looking for. You can start with a broad topic (like searching for "User model") and then, within those results, search for a more specific term (like "function save"). It's a powerful way to filter your code without having to do one giant, complicated search.
