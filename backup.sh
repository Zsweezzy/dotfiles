#!/usr/bin/env bash
# backup.sh — sync theme dotfiles into this repo, then commit & push.
# Every theme lives in its own folder at the repo root, mirroring your
# home-directory layout (e.g. ~/.config/kitty -> bwzs/.config/kitty).
# Usage: ./backup.sh [theme]   (defaults to "bwzs"; e.g. ./backup.sh nord)
# Run me after you tweak a theme; safe to run repeatedly.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

THEME="${1:-bwzs}"

# "source path|repo-relative destination"
PAIRS=(
  # Terminal
  "$HOME/.config/oh-my-posh|.config/oh-my-posh"
  "$HOME/.config/fastfetch|.config/fastfetch"
  "$HOME/.config/fish|.config/fish"
  "$HOME/.config/kitty|.config/kitty"
  "$HOME/.config/alacritty|.config/alacritty"

  # GTK
  "$HOME/.config/gtk-3.0|.config/gtk-3.0"
  "$HOME/.config/gtk-4.0|.config/gtk-4.0"
  "$HOME/.gtkrc-2.0|.gtkrc-2.0"

  # Editors / apps
  "$HOME/.config/nvim|.config/nvim"

  # Spicetify (user content only — Themes, Extensions, CustomApps)
  "$HOME/.spicetify/Themes|.spicetify/Themes"
  "$HOME/.spicetify/Extensions|.spicetify/Extensions"
  "$HOME/.spicetify/CustomApps|.spicetify/CustomApps"
)

for pair in "${PAIRS[@]}"; do
  src="${pair%%|*}"
  dst="$THEME/${pair#*|}"
  if [[ ! -e "$src" ]]; then
    echo "skip: $src (doesn't exist)"
    continue
  fi
  echo "sync: $src -> $dst"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    rsync -a --delete "$src/" "$dst/"
  elif [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    if [[ -d "$dst" ]]; then
      echo "  note: removing stale directory at $dst"
      rm -rf "$dst"
    fi
    rsync -a "$src" "$dst"
  else
    echo "skip: $src (not a regular file or dir)"
    continue
  fi
done

git add -A
if git diff --cached --quiet; then
  echo "Nothing to commit — repo up to date."
else
  git commit -m "Backup theme configs ($(date +%Y-%m-%d))"
  git push
  echo "Pushed to origin/main."
fi