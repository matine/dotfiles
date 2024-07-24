symlink() {
  from=$1
  to=$2

  if test -f $to; then
    chirp --confirm "$2 already exists, the following will override it."

    if [ $? -eq 1 ]; then
      chirp --skip "Skipping symlink"
      return
    else
      rm -r "$to"
    fi
  fi

  chirp --info "Symlinking $to"
  if ln -s "$from" "$to"; then
    chirp --success "Symlink created"
  else
    chirp --error "Failed to create symlink"
  fi
}
