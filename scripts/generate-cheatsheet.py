#!/usr/bin/env python3
"""
Title: generate-cheatsheet
Usage: ./scripts/generate-cheatsheet.py [-o OUTPUT]

Description:
Parses every file in this repo that defines a keybinding or an alias and
writes a single cheatsheet.md, grouped by tool.

Some tools have no config in this repo to parse -- Raycast keeps its hotkeys in
an app database, Lazygit ships its keys as built-in defaults -- so those
sections are hand-written. Anything between a pair of MANUAL markers is
preserved verbatim across runs -- edit it freely.

Stdlib only, no timestamp in the output, so re-running produces a clean diff.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

RAYCAST_TEMPLATE = """\
Raycast stores its hotkeys in an app database with no text export, so this
section is maintained by hand. Edit the rows below -- the generator preserves
everything between the MANUAL markers.

> **Note:** `CAPS` is Caps Lock, remapped by Karabiner to hyper
> (`⌘⌃⌥⇧`) — see the [Karabiner](#karabiner) section.

### Basics

|  |  |
| --- | --- |
| `⌘` + `⎵` | Open Raycast (remapped from Spotlight by Karabiner) |
| `⌘` + `,` | Open settings (once in Raycast) |
| _(assign a hotkey)_ | Settings > Extensions, search for the application, and record a hotkey there |

### Window

|  |  |
| --- | --- |
| `⌃⌥⌘` + `←` | Screen left |
| `⌃⌥⌘` + `→` | Screen right |
| `⌃⌥⌘` + `1` | Screen top left |
| `⌃⌥⌘` + `2` | Screen top right |
| `⌃⌥⌘` + `3` | Screen bottom left |
| `⌃⌥⌘` + `4` | Screen bottom right |
| `⌃⌥⌘` + `f` | Screen full width |
| `🌐︎` + `f` | Toggle full screen |

### Toggle apps

|  |  |
| --- | --- |
| `⌘` + `§` | Ghostty |
| `CAPS` + `k` | Search keybindings — fuzzy-searches this file (`raycast/search-keybindings.sh`) |
| `CAPS` + `n` | Notion |
| `CAPS` + `s` | Slack |
| `CAPS` + `m` | Schedule (My schedule) |
| `CAPS` + `a` | Calendar (cAlendar) |
| `CAPS` + `c` | Claude |
| `CAPS` + `h` | ChatGPT (cHat) |
| `CAPS` + `g` | Gemini |
| `CAPS` + `t` | Teams |
| `CAPS` + `i` | Google Chrome (internet) |

### Other shortcuts

|  |  |
| --- | --- |
| `⌘` + `x` | Clipboard history |
| `⌥` + `⎵` | Open Gemini mini chat |
| `⌥⌥` | Open Claude mini chat |
| `🌐︎` (hold) | Gemini dictation |
| `🌐︎` + `⌃` | Handy dictation |
| `🌐︎` + `⌃⌥` | Handy post-process with AI |

### Quicklink aliases

|  |  |
| --- | --- |
| `qs` | Search quicklinks |
| `qc` | Create quicklink |
| `youtube` (+ query) | Search YouTube |
| `search` (+ query) | Search Google |
| `t-` | Prefix for Timeline sites |
| `m-` | Prefix for my personal sites |
"""

LAZYGIT_TEMPLATE = """\
Start lazygit in the terminal with `lg`. These are lazygit's built-in defaults,
not repo config, so this section is maintained by hand -- the generator
preserves everything between the MANUAL markers.

> **Note:** the same key means different things depending on which panel has
> focus.

### Global & navigation

| Key | What it does |
| --- | --- |
| `q` | Quit lazygit |
| `?` | Show the keys available in the current panel |
| `z` | Undo last action |
| `Z` | Redo last undo action |
| `:` | Run any shell command, like raw git |
| `@` | Command log (shows all the raw git that lazygit has performed) |
| `p` | Pull |
| `P` | Push |
| `h` / `l` | Move between panels (arrow keys also work) |
| `j` / `k` | Move up/down within a list (arrow keys also work) |
| `[` / `]` | Switch tabs within a panel |
| `enter` | Drill into the selected item |
| `esc` | Cancel and go back to the previous view or panel |
| `0` | Focus the main view (diff display) |

### Files

| Key | What it does |
| --- | --- |
| `e` | Open the selected file in your external editor |
| `space` | Toggle staged state for the selected file |
| `a` | Toggle staged/unstaged for all files in the working tree |
| `c` | Commit staged changes — opens the commit message panel |
| `w` | Commit changes without running the pre-commit hook |
| `r` | Refresh the files list |
| `s` | Stash all changes |
| `M` | View options for resolving merge conflicts |

### Branches & tags

| Key | What it does |
| --- | --- |
| `space` | Checkout the selected branch |
| `n` | Create a new branch off the selected branch |
| `N` | Create a new branch and move the unpushed commits of the current branch to it — useful if you forgot to create a branch first |
| `R` | Rename the selected branch |
| `i` | Add the selected file to .gitignore or exclude |
| `M` | View options for merging the selected branch into the current branch (regular or squash merge) |
| `o` | Create a pull request for the selected branch |
| `enter` | View the commits of the selected branch |
"""

# (title, anchor, marker key, starting content if the section is missing)
MANUAL_SECTIONS = [
    ("Lazygit", "lazygit", "lazygit", LAZYGIT_TEMPLATE),
    ("Raycast", "raycast", "raycast", RAYCAST_TEMPLATE),
]


def manual_markers(key):
    return "<!-- BEGIN MANUAL: {} -->".format(key), "<!-- END MANUAL: {} -->".format(key)


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #


class Section:
    """One tool's worth of the cheatsheet.

    Pass `groups` -- a list of (subtitle, rows) -- to split the section into
    `###` sub-tables, the way the hand-written Lazygit section is laid out.
    `rows` then falls out of the groups, so the Contents count stays right and
    anything reading the flat list keeps working.
    """

    def __init__(self, title, anchor, rows=None, notes=None, groups=None):
        self.title = title
        self.anchor = anchor
        self.groups = groups or []
        if rows is None and self.groups:
            rows = [row for _, group in self.groups for row in group]
        self.rows = rows or []
        self.notes = notes or []


def rel(path):
    """Repo-relative path, for the Source column."""
    try:
        return str(Path(path).resolve().relative_to(REPO))
    except ValueError:
        return str(path)


def cell(text):
    """Escape a value so it survives a markdown table cell."""
    return str(text).replace("|", "\\|").replace("\n", " ").strip()


def code(text):
    """Wrap in a code span, widening the fence if the value contains backticks."""
    text = str(text).replace("|", "\\|").replace("\n", " ").strip()
    if not text:
        return ""
    fence = "`"
    while fence in text:
        fence += "`"
    pad = " " if text.startswith("`") or text.endswith("`") else ""
    return "{f}{p}{t}{p}{f}".format(f=fence, p=pad, t=text)


# Lua accepts both quote styles, sometimes in the same file.
LUA_STR = r"([\"'])((?:\\.|(?!\1).)*)\1"


def mask_lua(text, strings=True):
    """Blank out Lua comments, and optionally string bodies, preserving length.

    Indices into the result line up with the original, so callers can scan the
    masked copy for structure and then slice the original. Without this, an
    apostrophe in a comment reads as an unterminated string and swallows the
    rest of the file.
    """
    out = list(text)
    n = len(text)

    def blank(start, end):
        for j in range(start, min(end, n)):
            if out[j] != "\n":
                out[j] = " "

    def long_bracket(idx):
        """Level of a [[ or [=[ long bracket opening at idx, or None."""
        if idx >= n or text[idx] != "[":
            return None
        j = idx + 1
        while j < n and text[j] == "=":
            j += 1
        return j - idx - 1 if j < n and text[j] == "[" else None

    i = 0
    while i < n:
        if text.startswith("--", i):
            level = long_bracket(i + 2)
            if level is None:
                end = text.find("\n", i)
                end = n if end == -1 else end
            else:
                close = text.find("]" + "=" * level + "]", i + level + 4)
                end = n if close == -1 else close + level + 2
            blank(i, end)
            i = end
            continue
        level = long_bracket(i)
        if level is not None:
            close = text.find("]" + "=" * level + "]", i + level + 2)
            end = n if close == -1 else close + level + 2
            if strings:
                blank(i, end)
            i = end
            continue
        if text[i] in "\"'":
            quote = text[i]
            j = i + 1
            while j < n and text[j] != quote and text[j] != "\n":
                j += 2 if text[j] == "\\" else 1
            end = min(j + 1, n)
            if strings:
                blank(i, end)
            i = end
            continue
        i += 1
    return "".join(out)


def lua_field(text, name):
    """Value of `name = "..."` (or '...') in a Lua table body, or None."""
    found = re.search(r"\b" + name + r"\s*=\s*" + LUA_STR, mask_lua(text, strings=False))
    return found.group(2) if found else None


def first_lua_string(text):
    """The first quoted string in a Lua table body, or None."""
    found = re.search(LUA_STR, mask_lua(text, strings=False))
    return found.group(2) if found else None


def unquote(text):
    """Strip one layer of matching quotes."""
    text = text.strip()
    if len(text) >= 2 and text[0] == text[-1] and text[0] in "\"'":
        return text[1:-1]
    return text


def match_brace(text, open_idx, masked=None):
    """Index of the brace closing the one at open_idx, ignoring strings and comments."""
    scan = mask_lua(text) if masked is None else masked
    depth = 0
    for i in range(open_idx, len(scan)):
        if scan[i] == "{":
            depth += 1
        elif scan[i] == "}":
            depth -= 1
            if depth == 0:
                return i
    return -1


def block_after(text, pattern):
    """Inner text of the { ... } table following a regex match, or None."""
    masked = mask_lua(text)
    found = re.search(pattern, masked)
    if not found:
        return None
    open_idx = masked.find("{", found.end() - 1)
    if open_idx == -1:
        return None
    close_idx = match_brace(text, open_idx, masked)
    if close_idx == -1:
        return None
    return text[open_idx + 1 : close_idx]


def top_level_tables(inner):
    """Split a Lua table body into its top-level { ... } entries."""
    entries = []
    masked = mask_lua(inner)
    i = 0
    while i < len(inner):
        if masked[i] == "{":
            close = match_brace(inner, i, masked)
            if close == -1:
                break
            entries.append(inner[i : close + 1])
            i = close + 1
        else:
            i += 1
    return entries


def strip_jsonc(text):
    """Drop // and /* */ comments that sit outside strings."""
    out = []
    i = 0
    quote = False
    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""
        if quote:
            out.append(ch)
            if ch == "\\":
                out.append(nxt)
                i += 2
                continue
            if ch == '"':
                quote = False
        elif ch == '"':
            quote = True
            out.append(ch)
        elif ch == "/" and nxt == "/":
            while i < len(text) and text[i] != "\n":
                i += 1
            continue
        elif ch == "/" and nxt == "*":
            end = text.find("*/", i + 2)
            i = len(text) if end == -1 else end + 2
            continue
        else:
            out.append(ch)
        i += 1
    return "".join(out)


def read(path):
    """File text, or None if it is missing."""
    try:
        return Path(path).read_text(encoding="utf-8")
    except FileNotFoundError:
        return None


# --------------------------------------------------------------------------- #
# Parsers
# --------------------------------------------------------------------------- #

ALIAS_RE = re.compile(r"^\s*alias\s+([A-Za-z0-9_.\-]+)=(.+?)\s*$")
FUNC_RE = re.compile(r"^\s*([A-Za-z0-9_.\-]+)\s*\(\)\s*\{")


def parse_shell_aliases(path):
    """Aliases from a zsh file. A comment describing exactly one alias is used
    as its description; group comments covering several fall back to the
    expansion, which is the honest answer for 'what it does'."""
    text = read(path)
    if text is None:
        return None

    entries = []  # (name, expansion, comment, comment_id)
    comment = None
    comment_id = 0
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("#"):
            comment_id += 1
            comment = stripped.lstrip("#").strip()
            continue
        if not stripped:
            comment = None
            continue
        found = ALIAS_RE.match(line)
        if found:
            entries.append((found.group(1), unquote(found.group(2)), comment, comment_id))

    shared = {}
    for _, _, _, cid in entries:
        shared[cid] = shared.get(cid, 0) + 1

    rows = []
    for name, expansion, comment, cid in entries:
        if comment and shared.get(cid) == 1:
            what = "{} — {}".format(cell(comment), code(expansion))
        else:
            what = code(expansion)
        rows.append((code(name), what, code(rel(path))))
    return Section("Shell aliases", "shell-aliases", rows)


def parse_shell_functions(path):
    """Functions from a zsh file -- typed like aliases, so worth listing."""
    text = read(path)
    if text is None:
        return None

    lines = text.splitlines()
    rows = []
    comment = None
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("#"):
            comment = stripped.lstrip("#").strip()
            continue
        found = FUNC_RE.match(line)
        if not found:
            if not stripped:
                comment = None
            continue
        if comment:
            what = cell(comment)
        else:
            body = ""
            for follow in lines[idx + 1 :]:
                candidate = follow.strip()
                if candidate and candidate != "}":
                    body = candidate
                    break
            what = code(body) if body else "shell function"
        rows.append((code(found.group(1) + " <args>"), what, code(rel(path))))
        comment = None
    return Section("Shell functions", "shell-functions", rows)


def _git_value(raw):
    """Undo gitconfig's backslash escaping so the table shows the real command."""
    return re.sub(r'\\(["\\])', r"\1", raw.strip())


def parse_git_aliases(path):
    """The [alias] block of a gitconfig. Git lets the last definition win, so
    earlier duplicates are dead and get flagged as such."""
    text = read(path)
    if text is None:
        return None

    in_alias = False
    entries = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("["):
            in_alias = stripped.lower().startswith("[alias]")
            continue
        if not in_alias or not stripped or stripped.startswith("#"):
            continue
        if "=" not in stripped:
            continue
        name, expansion = stripped.split("=", 1)
        entries.append((name.strip(), _git_value(expansion)))

    seen = {}
    for name, _ in entries:
        seen[name] = seen.get(name, 0) + 1

    counted = {}
    rows = []
    notes = []
    for name, expansion in entries:
        counted[name] = counted.get(name, 0) + 1
        if expansion.startswith("!"):
            # A leading ! makes git run the rest as a shell command, not a subcommand.
            what = code(expansion[1:].strip()) + " _(shell)_"
        else:
            what = code("git " + expansion)
        if seen[name] > 1 and counted[name] < seen[name]:
            what += " — **shadowed**, a later `{}` wins".format(name)
            notes.append(
                "`git {}` is defined {} times; only the last definition is live.".format(
                    name, seen[name]
                )
            )
        rows.append((code("git " + name), what, code(rel(path))))
    return Section("Git aliases", "git-aliases", rows, sorted(set(notes)))


def _karabiner_key(event):
    """Render a Karabiner from/to event as a readable key string."""
    parts = []
    mods = event.get("modifiers") or {}
    if isinstance(mods, dict):
        wanted = mods.get("mandatory") or mods.get("optional") or []
    else:
        wanted = mods
    for mod in wanted:
        if mod == "any":
            continue
        parts.append(re.sub(r"^(left|right)_", "", mod))
    if event.get("key_code"):
        parts.append(re.sub(r"^(left|right)_", "", event["key_code"]))
    if event.get("shell_command"):
        return "run: " + event["shell_command"]
    return "+".join(parts) if parts else "?"


def parse_karabiner(path):
    text = read(path)
    if text is None:
        return None

    data = json.loads(text)
    rows = []
    source = code(rel(path))
    for profile in data.get("profiles", []):
        label = profile.get("name", "profile")

        for rule in profile.get("complex_modifications", {}).get("rules", []):
            for man in rule.get("manipulators", []):
                desc = man.get("description") or rule.get("description")
                key = _karabiner_key(man.get("from", {}))
                targets = [_karabiner_key(t) for t in man.get("to", [])]
                if not desc:
                    desc = "→ " + ", ".join(targets) if targets else "(no description)"
                elif targets:
                    desc = "{} ({})".format(cell(desc).rstrip("."), ", ".join(targets))
                rows.append((code(key), cell(desc), source))

        for mod in profile.get("simple_modifications", []):
            rows.append(
                (
                    code(_karabiner_key(mod.get("from", {}))),
                    "→ " + code(_karabiner_key(mod.get("to", [{}])[0])),
                    source,
                )
            )

        for fn in profile.get("fn_function_keys", []):
            src_key = _karabiner_key(fn.get("from", {}))
            dst = [_karabiner_key(t) for t in fn.get("to", [])]
            if dst == [src_key]:
                what = "Acts as a standard function key, not the media key"
            else:
                what = "→ " + ", ".join(dst)
            rows.append((code(src_key), what, source))

        if len(data.get("profiles", [])) > 1:
            rows[-1] = rows[-1][:2] + (source + " ({})".format(label),)
    return Section("Karabiner", "karabiner", rows)


def _lua_modes(entry):
    found = re.search(r"mode\s*=\s*\{([^}]*)\}", mask_lua(entry, strings=False))
    if found:
        modes = [m[1] for m in re.findall(LUA_STR, found.group(1))]
        return ",".join(modes) if modes else "n"
    return lua_field(entry, "mode") or "n"


def parse_nvim_keymaps(path):
    """Direct vim.keymap.set calls."""
    text = read(path)
    if text is None:
        return None

    rows = []
    starts = [m.start() for m in re.finditer(r"vim\.keymap\.set\s*\(", text)]
    for idx, start in enumerate(starts):
        end = starts[idx + 1] if idx + 1 < len(starts) else len(text)
        call = text[start:end]
        args = re.search(
            r"vim\.keymap\.set\s*\(\s*(\{[^}]*\}|\"[^\"]*\")\s*,\s*\"([^\"]+)\"\s*,\s*(.+)",
            call,
            re.S,
        )
        if not args:
            continue
        modes = ",".join(re.findall(r'"([^"]+)"', args.group(1))) or "n"
        lhs = args.group(2)
        desc = re.search(r'desc\s*=\s*"([^"]*)"', call)
        rhs = re.match(r'\s*"([^"]*)"', args.group(3))
        if desc:
            what = cell(desc.group(1))
            if rhs:
                what += " — " + code(rhs.group(1))
        elif rhs:
            what = code(rhs.group(1))
        else:
            what = "(lua function)"
        rows.append((code(lhs), "{} _(mode: {})_".format(what, modes), code(rel(path))))
    return rows


def parse_nvim_plugin_keys(directory):
    """keys = { ... } blocks in lazy.nvim plugin specs."""
    rows = []
    notes = []
    for path in sorted(Path(directory).glob("*.lua")):
        text = read(path)
        if text is None:
            continue
        if re.search(r"if\s+true\s+then\s+return\s*\{\s*\}\s*end", text):
            notes.append(
                "`{}` is disabled by an `if true then return {{}} end` guard, so its "
                "keymaps never load and are excluded.".format(rel(path))
            )
            continue

        plugin = re.search(r'return\s*\{\s*"([^"]+)"', text)
        label = plugin.group(1) if plugin else path.stem
        inner = block_after(text, r"\bkeys\s*=\s*\{")
        if inner is None:
            continue
        for entry in top_level_tables(inner):
            lhs = first_lua_string(entry)
            if not lhs:
                continue
            desc = lua_field(entry, "desc")
            what = cell(desc) if desc else "(lua function)"
            rows.append(
                (
                    code(lhs),
                    "{} — {} _(mode: {})_".format(what, cell(label), _lua_modes(entry)),
                    code(rel(path)),
                )
            )
    return rows, notes


def parse_nvim(config_dir):
    keymaps = parse_nvim_keymaps(Path(config_dir) / "lua" / "config" / "keymaps.lua")
    plugin_rows, notes = parse_nvim_plugin_keys(Path(config_dir) / "lua" / "plugins")
    rows = (keymaps or []) + plugin_rows
    if not rows:
        return None
    notes.append(
        "Everything else in Neovim comes from LazyVim's defaults, which live in the "
        "plugin itself and not in this repo."
    )
    return Section("Neovim", "neovim", rows, notes)


def parse_wezterm(path):
    text = read(path)
    if text is None:
        return None

    source = code(rel(path))
    rows = []
    notes = []

    leader = re.search(r"config\.leader\s*=\s*\{([^}]*)\}", text)
    if leader:
        rendered = "+".join(
            filter(
                None,
                [lua_field(leader.group(1), "mods"), lua_field(leader.group(1), "key")],
            )
        )
        rows.append((code(rendered), "**Leader** prefix for the bindings below", source))
        notes.append("`LEADER` in the table above means press {} first.".format(code(rendered)))

    inner = block_after(text, r"config\.keys\s*=\s*\{")
    for entry in top_level_tables(inner or ""):
        body = entry[1:-1]  # drop the entry's own braces so the action ends cleanly
        key = lua_field(body, "key")
        if key is None:
            continue
        rendered = "+".join(
            filter(None, [lua_field(body, "mods"), key.replace("\\\\", "\\")])
        )
        action = re.search(r"action\s*=\s*(.+)", body, re.S)
        if action:
            what = re.sub(r"\s+", " ", action.group(1)).strip().rstrip(",").strip()
            what = what.replace("wezterm.action.", "")
        else:
            what = "(unparsed action)"
        rows.append((code(rendered), code(what), source))
    return Section("WezTerm", "wezterm", rows, notes)


# Herdr names its actions after what they touch, so the sub-heading each
# binding belongs under can be read straight off the action. First match wins,
# and anything unclaimed -- the prefix leader, `help`, and any action added
# later that fits none of them -- falls through to Global.
#
# Widest container first, so an action naming two of them lands under the outer
# one: a hypothetical move_pane_to_workspace is a workspace command.
HERDR_GROUPS = [
    ("Workspaces", ("workspace",)),
    ("Tabs", ("tab",)),
    ("Panes", ("pane", "split", "zoom")),
]
# Containment order: a workspace holds tabs, a tab holds panes.
HERDR_ORDER = ["Global", "Workspaces", "Tabs", "Panes"]


def herdr_group(action):
    for title, needles in HERDR_GROUPS:
        if any(needle in action for needle in needles):
            return title
    return "Global"


TOML_TABLE_RE = re.compile(r"^\[([^\]]+)\]\s*$")
TOML_STR_RE = re.compile(r'"((?:\\.|[^"\\])*)"')


def parse_herdr(path):
    """The [keys] table of Herdr's config.toml. Each action binds a list of
    chords -- a prefixed one and a direct one -- so both land in the Key column.
    Comments are read like the zsh aliases: one that describes a single binding
    becomes its description, group comments stay out of the table."""
    text = read(path)
    if text is None:
        return None

    entries = []  # (action, [chords], comment, comment_id)
    in_keys = False
    comment = None
    comment_id = 0
    for line in text.splitlines():
        stripped = line.strip()
        table = TOML_TABLE_RE.match(stripped)
        if table:
            in_keys = table.group(1).strip() == "keys"
            comment = None
            continue
        if stripped.startswith("#"):
            # A comment block spanning several lines is still one comment.
            if comment is None:
                comment_id += 1
                comment = stripped.lstrip("#").strip()
            else:
                comment += " " + stripped.lstrip("#").strip()
            continue
        if not stripped:
            comment = None
            continue
        if not in_keys or "=" not in stripped:
            comment = None
            continue
        action, raw = stripped.split("=", 1)
        raw = raw.strip()
        chords = TOML_STR_RE.findall(raw) if raw.startswith("[") else [unquote(raw)]
        entries.append((action.strip(), chords, comment, comment_id))
        comment = None

    if not entries:
        return None

    shared = {}
    for _, _, _, cid in entries:
        shared[cid] = shared.get(cid, 0) + 1

    source = code(rel(path))
    grouped = {}
    notes = []
    prefix = None
    for action, chords, comment, cid in entries:
        keys = " / ".join(code(chord) for chord in chords)
        if action == "prefix":
            prefix = chords[0] if chords else None
            what = "**Prefix** leader for the `prefix+…` bindings below"
        else:
            what = action.replace("_", " ").capitalize()
        if comment and shared.get(cid) == 1:
            what += " — " + cell(comment)
        grouped.setdefault(herdr_group(action), []).append((keys, what, source))

    # Config order within a group, HERDR_ORDER between them, and an empty group
    # is simply left out rather than printed as a bare heading.
    groups = [(title, grouped[title]) for title in HERDR_ORDER if title in grouped]

    if prefix:
        notes.append(
            "`prefix` in the tables above means press {} first.".format(code(prefix))
        )
    return Section("Herdr", "herdr", None, notes, groups)


def parse_vscode(path):
    text = read(path)
    if text is None:
        return None

    data = json.loads(strip_jsonc(text))
    rows = []
    for binding in data:
        what = code(binding.get("command", "?"))
        args = binding.get("args") or {}
        if isinstance(args, dict) and args.get("text"):
            what += " — sends " + code(args["text"].encode("unicode_escape").decode())
        if binding.get("when"):
            what += " _(when: {})_".format(cell(binding["when"]))
        rows.append((code(binding.get("key", "?")), what, code(rel(path))))
    return Section("VS Code", "vs-code", rows)


# --------------------------------------------------------------------------- #
# Rendering
# --------------------------------------------------------------------------- #


def render_table(rows):
    lines = ["| Key / Alias | What it does | Source |", "| --- | --- | --- |"]
    for key, what, source in rows:
        lines.append("| {} | {} | {} |".format(key, what, source))
    return lines


def render(sections, manual_bodies):
    manual_titles = " and ".join(title for title, _, _, _ in MANUAL_SECTIONS)
    out = [
        "# Cheatsheet",
        "",
        "Every keybinding and alias defined in this repo, grouped by tool.",
        "",
        "> Generated by `scripts/generate-cheatsheet.py` — re-run it after changing any",
        "> config rather than editing this file. The {} sections are the".format(manual_titles),
        "> exception: they are hand-written and preserved across runs.",
        "",
        "Search it with `keys <terms>` or the Raycast \"Search keybindings\" command.",
        "Section shorthands: `lg` = Lazygit, `vm` = Neovim, `rc` = Raycast, `hr` = Herdr — so",
        "`keys lg push` narrows to one section.",
        "",
    ]

    contents = ["## Contents", ""]
    for section in sections:
        contents.append(
            "- [{}](#{}) ({} entries)".format(section.title, section.anchor, len(section.rows))
        )
    for title, anchor, _, _ in MANUAL_SECTIONS:
        contents.append("- [{}](#{}) (manual)".format(title, anchor))
    out += contents + [""]

    for section in sections:
        out.append("## " + section.title)
        out.append("")
        for subtitle, rows in section.groups or [(None, section.rows)]:
            if subtitle:
                out.append("### " + subtitle)
                out.append("")
            out += render_table(rows)
            out.append("")
        for note in section.notes:
            out.append("> **Note:** " + note)
            out.append("")

    for title, _, key, _ in MANUAL_SECTIONS:
        begin, end = manual_markers(key)
        out.append("## " + title)
        out.append("")
        out.append(begin)
        out.append(manual_bodies[key].rstrip())
        out.append(end)
        out.append("")
    return "\n".join(out)


def existing_manuals(output):
    """Keep whatever the user typed between the markers on a previous run."""
    text = read(output)
    bodies = {}
    for _, _, key, template in MANUAL_SECTIONS:
        bodies[key] = template
        if text is None:
            continue
        begin, end = manual_markers(key)
        start = text.find(begin)
        stop = text.find(end)
        if start == -1 or stop == -1 or stop < start:
            continue
        body = text[start + len(begin) : stop].strip("\n")
        if body.strip():
            bodies[key] = body
    return bodies


def main():
    parser = argparse.ArgumentParser(description="Build cheatsheet.md from the dotfiles.")
    parser.add_argument(
        "-o",
        "--output",
        default=str(REPO / "cheatsheet.md"),
        help="where to write the cheatsheet (default: %(default)s)",
    )
    args = parser.parse_args()
    output = Path(args.output)

    backup = REPO / "backup"
    candidates = [
        ("shell aliases", lambda: parse_shell_aliases(REPO / "shell" / "alias.zsh")),
        ("shell functions", lambda: parse_shell_functions(REPO / "shell" / "functions.zsh")),
        ("git aliases", lambda: parse_git_aliases(backup / ".gitconfig")),
        (
            "karabiner",
            lambda: parse_karabiner(backup / ".config" / "karabiner" / "karabiner.json"),
        ),
        ("neovim", lambda: parse_nvim(backup / ".config" / "nvim")),
        ("wezterm", lambda: parse_wezterm(backup / ".config" / "wezterm" / "wezterm.lua")),
        ("herdr", lambda: parse_herdr(backup / ".config" / "herdr" / "config.toml")),
        (
            "vs code",
            lambda: parse_vscode(
                backup / "Library" / "Application Support" / "Code" / "User" / "keybindings.json"
            ),
        ),
    ]

    sections = []
    for label, build in candidates:
        try:
            section = build()
        except Exception as err:  # a malformed config should not kill the run
            print("  !! {:<16} failed to parse: {}".format(label, err), file=sys.stderr)
            continue
        if section is None:
            print("  -- {:<16} not found, skipped".format(label))
            continue
        sections.append(section)
        print("  ok {:<16} {} entries".format(label, len(section.rows)))

    output.write_text(render(sections, existing_manuals(output)), encoding="utf-8")
    total = sum(len(s.rows) for s in sections)
    print("\nWrote {} ({} entries across {} sections).".format(rel(output), total, len(sections)))


if __name__ == "__main__":
    main()
