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

# add_http <name> <url> [token_var] [header...]
# Without token_var the server is expected to authenticate interactively via
# /mcp -> Authenticate. With it, the Authorization header is stored with the
# variable unexpanded. Pass "" as token_var to send extra headers without one.
# Skips servers that already exist, so re-running this never drops a stored
# credential and forces you to re-authenticate.
add_http() {
  name=$1 url=$2 token_var=$3
  shift 2
  [ $# -gt 0 ] && shift

  if claude mcp list 2>/dev/null | grep -qE "(^|[[:space:]])$name:"; then
    chirp --skip "$name is already registered"
    return
  fi

  if [ -n "$token_var" ]; then
    # A missing value only surfaces as a 401 at connect time, which reads like a
    # bad token rather than an unset one, so say so now.
    eval "token=\$$token_var"
    if [ -z "$token" ]; then
      chirp --warn "$token_var is not set - add it to ~/.zshrc.local and open a new shell"
    fi

    set -- "$@" "Authorization: Bearer \${$token_var}"
  fi

  # Turn each remaining header into a --header flag (sh has no arrays).
  for header do
    set -- "$@" --header "$header"
    shift
  done

  claude mcp add --transport http --scope user "$name" "$url" "$@"

  chirp --success "Registered $name"
}

chirp --info "Registering servers"

# GitHub's MCP endpoint does not support dynamic client registration, so the
# interactive flow fails with "Incompatible auth server". A fine-grained PAT
# passed as a header is the working path. X-MCP-Toolsets limits the tools
# loaded; keep it in step with the mcp__github__ allow list in settings.json.
add_http github https://api.githubcopilot.com/mcp GITHUB_MCP_TOKEN \
  "X-MCP-Toolsets: repos,issues,pull_requests,actions"

chirp --info "Restart Claude Code, then run /mcp to verify"
