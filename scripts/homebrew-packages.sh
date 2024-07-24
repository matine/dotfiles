. $DOTFILES/scripts/symlink.sh

chirp --title "Install Homebrew packages"

symlink "$DOTFILES/backup/homebrew/Brewfile" "$HOME/.Brewfile"

chirp --info "Installing homebrew packages"

brew bundle --global