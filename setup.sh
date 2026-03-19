#!/bin/bash
# Dotfiles setup script
# Run this on a fresh machine after cloning the repo to ~/dotfiles

set -e

DOTFILES="$HOME/dotfiles"

info() { echo "  $1"; }
ok()   { echo "✓ $1"; }

symlink() {
  local src="$1"
  local dst="$2"
  if [ -L "$dst" ]; then
    ok "already linked: $dst"
  elif [ -e "$dst" ]; then
    echo "! $dst exists and is not a symlink — skipping (back it up manually if needed)"
  else
    ln -s "$src" "$dst"
    ok "linked: $dst → $src"
  fi
}

echo ""
echo "=== Setting up dotfiles ==="
echo ""

# ~/.config → ~/dotfiles/.config
# All app configs (nvim, lazygit, kitty, etc.) live here
mkdir -p "$HOME/.config"
symlink "$DOTFILES/.config" "$HOME/.config"

# ~/.zshenv — sets ZDOTDIR so zsh picks up ~/dotfiles/zsh/.zshrc
symlink "$DOTFILES/.zshenv" "$HOME/.zshenv"

# ~/.xinitrc — X session startup (awesome wm, display layout, etc.)
symlink "$DOTFILES/.xinitrc" "$HOME/.xinitrc"

# ~/.local/bin scripts
mkdir -p "$HOME/.local/bin"
symlink "$DOTFILES/bin/nvr"                 "$HOME/.local/bin/nvr"
symlink "$DOTFILES/bin/nvim-lazygit-edit"   "$HOME/.local/bin/nvim-lazygit-edit"

echo ""
echo "=== Done ==="
echo ""
echo "Next steps:"
echo "  1. Install packages (see README.md)"
echo "  2. Open nvim — plugins install automatically via lazy.nvim"
echo "  3. Restart your shell"
echo ""
