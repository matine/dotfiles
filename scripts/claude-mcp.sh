chirp --title "Register Claude Code MCP servers"

# User-scope MCP servers live in ~/.claude.json, which is deliberately NOT
# tracked in this repo: it mixes real config with per-project session state and
# account credentials. This script rebuilds the durable part on a new machine.
#
# Servers are registered without secrets. Auth happens interactively afterwards
# via /mcp -> Authenticate, so no token ever lands in git.

if ! command -v claude >/dev/null; then
  chirp --warn "Claude Code CLI not found, skipping MCP setup"
  exit 0
fi

# add_http <name> <url>
# Skips servers that already exist, so re-running this never drops a stored
# OAuth token and forces you to re-authenticate.
add_http() {
  if claude mcp list 2>/dev/null | grep -qE "(^|[[:space:]])$1:"; then
    chirp --skip "$1 is already registered"
    return
  fi

  claude mcp add --transport http --scope user "$1" "$2"
  chirp --success "Registered $1"
}

chirp --info "Registering servers"
add_http github https://api.githubcopilot.com/mcp

# For a server that genuinely needs a static token, pass it by reference so the
# value stays in ~/.zshrc.local and only the variable name is committed:
#
#   claude mcp add --transport http --scope user example https://example.com/mcp \
#     --header "Authorization: Bearer \${EXAMPLE_TOKEN}"

chirp --info "Run /mcp in Claude Code and pick Authenticate for each server"
