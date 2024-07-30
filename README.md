# Dotfiles

## Before switching mac

TODO: Automate this process

1. Dump your current installed apps status as a brewfile (Warning: this will overwrite the old one)

```bash
brew bundle dump --force --file=~/dotfiles/backup/homebrew/Brewfile --describe
```

## Installation

1. [Generate a new public and private SSH key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) by running:

```bash
curl https://raw.githubusercontent.com/driesvints/dotfiles/HEAD/ssh.sh | sh -s "<your-email-address>"
```

2. Clone the repository directly in your home folder:

```bash
git clone https://github.com/matine/dotfiles ~/dotfiles
```

3. Navigate to the `dotfiles` directory:

```bash
cd ~/dotfiles
```

4. Run the setup script

```bash
./setup.sh
```

5. Open the menu

```bash
sh $DOTFILES/scripts/menu.sh
```

## Features

- Setup the shell (zsh)
- Setup the GIT
- Install homebrew and packages
- Install global (P)NPM packages
- Configure MacOS
- Configure Karabiner
- Configure VSCode
- Configure Wezterm
