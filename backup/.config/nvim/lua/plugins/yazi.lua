-- Opens yazi in a floating window over nvim, so nvim stays the long-running
-- process. Enter on a file loads it as a buffer here instead of spawning a
-- second nvim, which is what makes toggling back and forth possible.
return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  -- Also expose the command so the startup autocmd below can load the plugin
  -- on demand, before VeryLazy has fired.
  cmd = "Yazi",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  opts = {
    -- Leave directory arguments to snacks explorer; this keeps netrw untouched.
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
  },
  keys = {
    -- Shadows LazyVim's "Split Window Below"; <c-w>s still does that.
    { "<leader>-", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Open yazi at the current file" },
    { "<leader>e", "<cmd>Yazi cwd<cr>", desc = "Open yazi in nvim's working directory" },
    -- Shadows LazyVim's "Increase Window Height"; smart-splits has that on <c-a-k>.
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume the last yazi session" },
  },
  -- Replace the LazyVim dashboard: a bare `nvim` opens yazi at the cwd. The
  -- dashboard itself is switched off in lua/plugins/snacks.lua. `init` runs
  -- during startup, before the plugin loads, so the autocmd is registered in
  -- time for VimEnter.
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("yazi_startup", { clear = true }),
      nested = true,
      callback = function()
        -- Only for a bare `nvim`: no file arguments, and an untouched buffer.
        -- This leaves `nvim file`, `nvim .`, piped stdin and session restores
        -- alone.
        if vim.fn.argc() > 0 then
          return
        end
        local buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_get_name(buf) ~= "" then
          return
        end
        if vim.bo[buf].modified or vim.bo[buf].filetype ~= "" then
          return
        end
        if vim.api.nvim_buf_line_count(buf) > 1 then
          return
        end
        vim.schedule(function()
          vim.cmd("Yazi cwd")
        end)
      end,
    })
  end,
}
