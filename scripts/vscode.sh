. $DOTFILES/scripts/symlink.sh

chirp --title "Configure VSCode"

symlink "$DOTFILES/backup/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
symlink "$DOTFILES/backup/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
symlink "$DOTFILES/backup/vscode/snippets" "$HOME/Library/Application Support/Code/User/snippets"
symlink "$DOTFILES/backup/vscode/extensions.json" "$HOME/.vscode/extensions/extensions.json"

chirp --info "Installing extensions from backup json file"
cat $DOTFILES/backup/vscode/extensions.json | jq -r '.[].identifier.id' | xargs -I {} code --install-extension {} --force