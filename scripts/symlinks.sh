chirp --title "Symlinking all the things"

chirp --info "Linking files necessary for ZSH, GIT, Homebrew, VScode, Wezterm, Karabiner"
cd ~/dotfiles/home
stow . -t ~/
cd ~/dotfiles