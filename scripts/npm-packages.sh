chirp --title "Install (P)NPM packages"

if ! command -v pnpm >/dev/null; then
  chirp --info "Installing pnpm"
  brew install pnpm
  chirp --success "Installed pnpm"
else 
  chirp --success "pnpm is already installed"
fi

chirp --info "Installing packages"
pnpm i -g @sanity/cli
pnpm i -g diff-so-fancy
pnpm i -g eslint_d
pnpm i -g gatsby-cli
pnpm i -g kill-port
pnpm i -g nodemon
pnpm i -g npm-check-updates
pnpm i -g npmrc
pnpm i -g serve
pnpm i -g speed-test
pnpm i -g svgo
pnpm i -g typescript
pnpm i -g vercel
pnpm i -g wipe-modules
pnpm i -g yarn