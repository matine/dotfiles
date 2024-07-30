echo "--- Initial Mac set up ---"

echo "Showing hidden files by default..."
defaults write com.apple.finder AppleShowAllFiles -bool true

echo "Making dotfiles script files executable..."
chmod +x ~/dotfiles/scripts/*

echo "Temporarily symlinking necessary files (.zshrc, .zshenv, .zprofile, .antigenrc, .Brewfile)..."
ln -s ~/dotfiles/backup/.zshrc ~/.zshrc
ln -s ~/dotfiles/backup/.zshenv ~/.zshenv
ln -s ~/dotfiles/backup/.zprofile ~/.zprofile
ln -s ~/dotfiles/backup/.antigenrc ~/.antigenrc
ln -s ~/dotfiles/backup/.Brewfile ~/.Brewfile

exho "Refreshing shell..."
source ~/.zshrc

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing all packages from Brewfile..."
brew bundle --global

echo "Removing symlinks so stow can handle them..."
rm ~/.zshrc
rm ~/.zshenv
rm ~/.zprofile
rm ~/.antigenrc
rm ~/.Brewfile

echo "Symlinking backup folder with stow..."
cd ~/dotfiles/backup
stow . -t ~/
cd ~/dotfiles

echo "Initial setup complete."
echo "Close this terminal, open Wezterm and run the rest of the installation '~/dotfiles/scripts/install.sh'"