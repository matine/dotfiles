. $DOTFILES/scripts/symlink.sh

chirp --title "Setup GIT"

symlink "$DOTFILES/backup/gitconfig" "$HOME/.gitconfig"
symlink "$DOTFILES/backup/gitignore" "$HOME/.gitignore"
