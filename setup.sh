chirp --title "Mac set up"

chirp --info "Making dotfiles script files executable"
chmod +x $DOTFILES/scripts/*

chirp --info "Opening menu"
sh $DOTFILES/scripts/menu.sh
