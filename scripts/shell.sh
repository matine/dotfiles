. $DOTFILES/scripts/symlink.sh

chirp --title "Setup shell (zsh)"

symlink "$DOTFILES/backup/zshrc" "$HOME/.zshrc"
symlink "$DOTFILES/backup/zshenv" "$HOME/.zshenv"
symlink "$DOTFILES/backup/zprofile" "$HOME/.zprofile"
symlink "$DOTFILES/backup/antigenrc" "$HOME/.antigenrc"
