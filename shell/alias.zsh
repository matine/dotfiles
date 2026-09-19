# Show this file
alias a="bat $DOTFILES/shell/alias.zsh"

# Show every keybinding and alias (opens rendered, see editorAssociations in VSCode settings)
alias cheat="code $DOTFILES/cheatsheet.md"

# Shell and PATH helpers
alias path="echo $PATH | tr ':' '\n'"
alias src="source ~/.zshrc"
alias o="open ."
alias pk="bat package.json"

# Saner defaults
alias mkdir='mkdir -pv'
alias mv="mv -v"
alias rm="rm -i -v"

# (P)NPM
alias ni="pnpm i"
alias ns="pnpm start"
alias nd="pnpm dev"
alias nt="pnpm test"
alias nb="pnpm build"

# GIT
alias g="git"
alias lg="lazygit"

# Homebrew commands
alias bi="brew install"
alias bu="brew uninstall"
alias bup="brew upgrade"
alias bfile="brew bundle dump --force --file=$DOTFILES/backup/.Brewfile"

# Remap ls to eza
alias ls="eza --all --hyperlink"
alias ls-p="eza --all --absolute=on"

# Show git alias
alias gita="git config --get-regexp alias"

# Dotfiles helpers
alias dot-link="cd ~/dotfiles/scripts/ && sh ./symlinks.sh"