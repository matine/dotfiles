#!/usr/bin/env python3
"""
Title: restrict-write-paths
Usage: PreToolUse hook on Write|Edit|NotebookEdit (reads hook JSON on stdin)

Description:
Denies any file write whose target resolves outside the allowed roots. The
sandbox already confines Bash to these directories; this closes the same gap
for the file tools, which the sandbox does not cover.

Symlinks are resolved first, so ~/.claude/CLAUDE.md is allowed once stow has
linked it into ~/dotfiles, and a symlink pointing out of the repo is not.
"""

import json
import os
import sys

ALLOWED = [
    os.path.realpath(os.path.expanduser(p))
    for p in ("~/ClaudeAccess", "~/dotfiles")
]


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return  # malformed input: stay out of the way rather than block everything

    path = (payload.get("tool_input") or {}).get("file_path")
    if not path:
        return

    target = os.path.realpath(os.path.expanduser(path))
    if any(target == root or target.startswith(root + os.sep) for root in ALLOWED):
        return

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                f"{target} is outside ~/ClaudeAccess and ~/dotfiles. "
                "Edit the file in ~/dotfiles/backup and let stow symlink it."
            ),
        }
    }))


main()
