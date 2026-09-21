# CLAUDE.md

## Dotfiles

Personal macOS dotfiles: config symlinked into `~` with GNU `stow`, plus install
scripts. `README.md` covers setting up a new machine.

- **`backup/` is the stow package** — its tree mirrors the home directory, so a
  config for `~/.config/nvim/` lives at `backup/.config/nvim/`. Add files there,
  then `scripts/symlinks.sh`. Everything else: `shell/` (sourced by `.zshrc`),
  `scripts/` (install + config), `bin/` (CLIs on `PATH`), `raycast/`.
- **`cheatsheet.md` is generated** — never edit it by hand; run
  `scripts/generate-cheatsheet.py` after changing a keybinding or alias. Its
  Lazygit and Raycast sections are hand-written inside the generator, between
  `MANUAL` markers.
- **No secrets in this repo, ever.** Credentials go in `~/.zshrc.local`
  (untracked, outside the repo, sourced at the end of `.zshrc`).
- Scripts log with `chirp --title/--info/--error`, not `echo`, and new ones get
  registered in `scripts/menu.sh`.
- Prompt me to run `dot-link` when a change has been made in the backup folder and they need to be symlinked
