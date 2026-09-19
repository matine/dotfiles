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

9. Create your machine-local secrets file — see [Secrets](#secrets) below. Nothing in
   this repo contains credentials, so tokens will be missing until you do this.

## Secrets

Credentials are **never** stored in this repo. They live in `~/.zshrc.local`, which
sits outside `~/dotfiles` so that `git add` in this repo cannot pick it up. `~/.zshrc`
sources it at the end of the file:

```bash
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

`.zshrc.local` is also listed in the global git excludes (`backup/.gitignore`, symlinked
to `~/.gitignore` via `core.excludesfile`) and in this repo's own `.gitignore`, as a
safety net in case a copy ever lands inside the repo.

### On a new machine

`~/.zshrc.local` is intentionally **not** created by `initial-setup.sh` — there is nothing
to copy, because the values are not in this repo. Create it by hand after cloning:

```bash
touch ~/.zshrc.local && chmod 600 ~/.zshrc.local
```

Then add the exports you need, for example:

```bash
export ANTHROPIC_API_KEY='...'
export NPM_TOKEN='...'
export CLOUDSMITH_TOKEN='...'
```

Retrieve the current values from your password manager, not from another machine's
shell history. Keep the file at mode `600`.

### Adding a new credential

Put the `export` in `~/.zshrc.local`. Never in `backup/.zshrc`, `shell/exports.zsh`, or
any other tracked file. If you are unsure whether something is tracked:

```bash
cd ~/dotfiles && git check-ignore -v <path> || git ls-files --error-unmatch <path>
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
- Configure Herdr
- Keep credentials out of version control (see [Secrets](#secrets))
