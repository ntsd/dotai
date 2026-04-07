#!/usr/bin/env bash
set -euo pipefail

SOURCE="https://github.com/ntsd/dotai"
TARGET="${TARGET:-$HOME/dotai}"

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_via_git() {
  if [[ -d "$TARGET/.git" ]]; then
    echo "Updating existing repository in $TARGET"
    git -C "$TARGET" pull --ff-only
  else
    echo "Cloning repository to $TARGET"
    rm -rf "$TARGET"
    git clone "$SOURCE" "$TARGET"
  fi
}

main() {
  echo "Installing DotAI..."

  if ! has_cmd "git"; then
    echo "Error: git is required." >&2
    exit 1
  fi

  install_via_git

  if has_cmd "make"; then
    echo "Running make install"
    make -C "$TARGET" install
  else
    echo "make not found; run installation manually with:"
    echo "  cd $TARGET && make install"
  fi

  echo "Done."
}

main "$@"
