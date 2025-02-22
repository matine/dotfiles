# ================================================================================ #
# Config
# ================================================================================ #
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_TAB_TITLE_CONCAT_FOLDER_PROCESS=true
DISABLE_AUTO_TITLE="true"

# Case insensitve autocomplete
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Turn on correction suggestions
unsetopt correct_all
setopt correct
# Turn on 256color support
TERM=xterm-256color

# Antigen
source $HOMEBREW/share/antigen/antigen.zsh
antigen init ~/.antigenrc

# ZSH
source $DOTFILES/shell/alias.zsh
source $DOTFILES/shell/exports.zsh
source $DOTFILES/shell/functions.zsh

# Zoxide
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

eval "$(pyenv init --path)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Make all bins executable
chmod +x $DOTFILES/bin/*
# Make all shell scripts executable
chmod +x $DOTFILES/scripts/*
# Add bin to PATH
export PATH=$PATH:$DOTFILES/bin

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# pnpm
export PNPM_HOME="/Users/matinechabrier/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/Users/matinechabrier/.bun/_bun" ] && source "/Users/matinechabrier/.bun/_bun"
