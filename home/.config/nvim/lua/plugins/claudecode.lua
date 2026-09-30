-- Claude runs in its own herdr pane, not inside nvim, so the plugin only runs
-- the IDE server. Loaded eagerly so the server is up (and Claude can auto-connect
-- via CLAUDE_CODE_AUTO_CONNECT_IDE) without first pressing a <leader>a key.
return {
  "coder/claudecode.nvim",
  lazy = false,
  opts = {
    terminal = {
      provider = "none",
    },
  },
}
