chirp --title "Installing all the things"

sh $DOTFILES/scripts/symlinks.sh
sh $DOTFILES/scripts/homebrew.sh
sh $DOTFILES/scripts/homebrew-packages.sh
sh $DOTFILES/scripts/npm-packages.sh
sh $DOTFILES/scripts/macos.sh