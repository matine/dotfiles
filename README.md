# Dotfiles

## Before switching mac

TODO: Automate this process

1. Dump your current installed apps status as a brewfile (Warning: this will overwrite the old one)

```bash
bfile
```

## Installation

1. [Generate a new public and private SSH key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) by running:

```bash
curl https://raw.githubusercontent.com/driesvints/dotfiles/HEAD/ssh.sh | sh -s "matine.chabrier@gmail.com"
```

2. Copy your public key to your github account

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

3. Clone the repository directly in your home folder:

```bash
git clone https://github.com/matine/dotfiles ~/dotfiles
```

4. Navigate to the `dotfiles/scripts` directory:

```bash
cd ~/dotfiles/scripts
```

5. Note that the homebrew path is different for Intel and Silicon machines, so you will need to ensure the correct one is set in the .zshenv file.

6. Run the initial setup script

```bash
sh ./initial-setup.sh
```

7. Open the menu (optional)

```bash
sh ./menu.sh
```

8. Set the repo to use SSH to bypass logins on push etc

```bash
git remote set-url origin git@github.com:matine/dotfiles
```

## Features

- Setup the shell (zsh)
- Setup GIT
- Install homebrew and packages
- Install global (P)NPM packages
- Configure MacOS
- Configure Karabiner
- Configure VSCode
- Configure Wezterm
