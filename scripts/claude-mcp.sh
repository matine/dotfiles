chirp --title "Register Claude Code MCP servers"

# User-scope MCP servers live in ~/.claude.json, which is deliberately NOT
# tracked in this repo: it mixes real config with per-project session state and
# account credentials. This script rebuilds the durable part on a new machine.
#
# No secret is written here. A server needing a static token gets it by
# reference, so only the variable name is committed; the value lives in
# ~/.zshrc.local and Claude Code expands it at connect time.

if ! command -v claude >/dev/null; then
  chirp --warn "Claude Code CLI not found, skipping MCP setup"
  exit 0
fi

# add_http <name> <url> [token_var]
# Without token_var the server is expected to authenticate interactively via
# /mcp -> Authenticate. With it, the Authorization header is stored with the
# variable unexpanded.
# Skips servers that already exist, so re-running this never drops a stored
# credential and forces you to re-authenticate.
add_http() {
  if claude mcp list 2>/dev/null | grep -qE "(^|[[:space:]])$1:"; then
    chirp --skip "$1 is already registered"
    return
  fi

  if [ -n "$3" ]; then
    # A missing value only surfaces as a 401 at connect time, which reads like a
    # bad token rather than an unset one, so say so now.
    eval "token=\$$3"
    if [ -z "$token" ]; then
      chirp --warn "$3 is not set - add it to ~/.zshrc.local and open a new shell"
    fi

    claude mcp add --transport http --scope user "$1" "$2" \
      --header "Authorization: Bearer \${$3}"
  else
    claude mcp add --transport http --scope user "$1" "$2"
  fi

  chirp --success "Registered $1"
}

chirp --info "Registering servers"

# GitHub's MCP endpoint does not support dynamic client registration, so the
# interactive flow fails with "Incompatible auth server". A fine-grained PAT
# passed as a header is the working path.
add_http github https://api.githubcopilot.com/mcp GITHUB_MCP_TOKEN

chirp --info "Restart Claude Code, then run /mcp to verify"
