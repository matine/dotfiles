echo "--- Initial Mac set up ---"

echo "Making dotfiles script files executable"
chmod +x ~/dotfiles/scripts/*

echo "Show hidden files by default"
defaults write com.apple.finder AppleShowAllFiles -bool true

echo "Symlinking shell files (zshrc, zshenv, zprofile, antigenrc)"
ln -s ~/dotfiles/backup/zshrc ~/.zshrc
ln -s ~/dotfiles/backup/zshenv ~/.zshenv
ln -s ~/dotfiles/backup/zprofile ~/.zprofile
ln -s ~/dotfiles/backup/antigenrc ~/.antigenrc

echo "Symlinking git files"
ln -s ~/dotfiles/backup/gitconfig ~/.gitconfig
ln -s ~/dotfiles/backup/gitignore ~/.gitignore

echo "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Symlinking Brewfile"
ln -s ~/dotfiles/backup/homebrew/Brewfile ~/.Brewfile

echo "Installing all packages from Brewfile"
brew bundle --global

echo "Refresh shell"
source ~/.zshrc