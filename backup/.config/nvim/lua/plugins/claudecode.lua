-- Claude runs in its own herdr pane, not inside nvim, so the plugin only runs
-- the IDE server. Run /ide in Claude to connect it for selection context,
-- diagnostics and diff review.
return {
  "coder/claudecode.nvim",
  opts = {
    terminal = {
      provider = "none",
    },
  },
}
