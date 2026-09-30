echo "--- Initial Mac set up ---"

echo "Showing hidden files by default..."
defaults write com.apple.finder AppleShowAllFiles -bool true

echo "Making dotfiles script files executable..."
chmod +x ~/dotfiles/scripts/*

echo "Temporarily symlinking necessary files (.zshrc, .zshenv, .zprofile, .antigenrc, .Brewfile)..."
ln -s ~/dotfiles/home/.zshrc ~/.zshrc
ln -s ~/dotfiles/home/.zshenv ~/.zshenv
ln -s ~/dotfiles/home/.zprofile ~/.zprofile
ln -s ~/dotfiles/home/.antigenrc ~/.antigenrc
ln -s ~/dotfiles/home/.Brewfile ~/.Brewfile

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

echo "Symlinking home folder with stow..."
cd ~/dotfiles/home
stow . -t ~/ --no-folding
cd ~/dotfiles

echo "Initial setup complete."
echo "Close this terminal, open Wezterm and run the rest of the installation '~/dotfiles/scripts/install-all.sh'"