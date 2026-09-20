#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search keybindings
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ⌨️
# @raycast.packageName Dotfiles
# @raycast.argument1 { "type": "text", "placeholder": "hr, lg, vm, rc", "optional": true }

# Documentation:
# @raycast.description Fuzzy-search cheatsheet.md for a keybinding or alias. Section shorthands show that section alone: lg = lazygit, vm = neovim, rc = raycast, hr = herdr — add a sub-section to narrow further, like "hr tab". Leave the argument empty to list everything.
# @raycast.author Matine Chabrier

# Raycast runs this with a bare PATH and none of the zsh dotfiles, so $DOTFILES
# does not exist here -- resolve the repo from this script's own location, and
# force plain output since Raycast renders escape codes literally.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYS="$DIR/bin/keys"

if [ ! -x "$KEYS" ]; then
	echo "keys not found or not executable at $KEYS"
	exit 1
fi

if [ "$#" -eq 0 ] || [ -z "${1:-}" ]; then
	exec "$KEYS" --all --plain
fi

exec "$KEYS" --plain "$@"
