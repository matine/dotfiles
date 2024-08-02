# Show this file
alias alias="bat $DOTFILES/shell/alias.zsh"

# Shell and PATH helpers
alias path="echo $PATH | tr ':' '\n'"
alias src="source ~/.zshrc"
alias o="open ."
alias pk="bat package.json"

# Saner defaults
alias mkdir='mkdir -pv'
alias mv="mv -v"
alias rm="rm -i -v"

# NPM
alias ns="npm start"
alias nd="npm dev"
alias nt="npm test"

# Homebrew commands
alias bi="brew install"
alias bu="brew uninstall"
alias bup="brew upgrade"
alias bfile="brew bundle dump --force --file=$DOTFILES/backup/.Brewfile --describe"

# Remap ls to eza
alias ls="eza --hyperlink"
alias ls-p="eza --absolute=on"
