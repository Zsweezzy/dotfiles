#!/usr/bin/env bash
# backup.sh — sync theme dotfiles into this repo, then commit & push.
# Every theme lives in its own folder at the repo root, split into named
# *component* folders (the app/system owning the config). The component
# folder itself is the app folder, e.g.
#   ~/.config/kitty/kitty.conf      -> bwzs/kitty/kitty.conf
#   ~/.local/share/plasma/desktoptheme -> bwzs/plasma/desktoptheme
#   ~/.local/share/wallpapers       -> bwzs/wallpapers
# Usage: ./backup.sh [theme]   (defaults to "bwzs"; e.g. ./backup.sh nord)
# Run me after you tweak a theme; safe to run repeatedly.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

THEME="${1:-bwzs}"

# "source path|repo-relative destination"
PAIRS=(
  # Terminal
  "$HOME/.config/oh-my-posh|oh-my-posh"
  "$HOME/.config/fastfetch|fastfetch"
  "$HOME/.config/fish|fish"
  "$HOME/.config/kitty|kitty"
  "$HOME/.config/alacritty|alacritty"

  # GTK
  "$HOME/.config/gtk-3.0|gtk/gtk-3.0"
  "$HOME/.config/gtk-4.0|gtk/gtk-4.0"
  "$HOME/.gtkrc-2.0|gtk/.gtkrc-2.0"

  # Editors / apps
  "$HOME/.config/nvim|nvim"

  # mpv (Flatpak) — YouTube-style OSC + Tokyo Night Moon colors
  "$HOME/.var/app/io.mpv.Mpv/config/mpv|mpv"

  # Spicetify (user content only — Themes, Extensions, CustomApps,
  # plus the spicetify-cli config & active theme)
  "$HOME/.spicetify/Themes|spicetify/workspace/Themes"
  "$HOME/.spicetify/Extensions|spicetify/workspace/Extensions"
  "$HOME/.spicetify/CustomApps|spicetify/workspace/CustomApps"
  "$HOME/.config/spicetify/Themes|spicetify/config/Themes"
  "$HOME/.config/spicetify/config-xpui.ini|spicetify/config/config-xpui.ini"

  # KDE Plasma theme
  "$HOME/.local/share/plasma/desktoptheme|plasma/desktoptheme"
  "$HOME/.local/share/plasma/look-and-feel|plasma/look-and-feel"
  "$HOME/.local/share/plasma/plasmoids|plasma/plasmoids"
  "$HOME/.local/share/plasma/wallpapers|plasma/wallpapers"
  "$HOME/.local/share/color-schemes|colorschemes"
  "$HOME/.local/share/aurorae|aurorae"
  "$HOME/.local/share/wallpapers|wallpapers"

  # KDE config (theme/layout only — no activity history, wallets, or session state)
  "$HOME/.config/kdeglobals|kde/kdeglobals"
  "$HOME/.config/kwinrc|kde/kwinrc"
  "$HOME/.config/kwinrulesrc|kde/kwinrulesrc"
  "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc|plasma/plasma-org.kde.plasma.desktop-appletsrc"
  "$HOME/.config/plasmashellrc|plasma/plasmashellrc"
  "$HOME/.config/plasmarc|plasma/plasmarc"
  "$HOME/.config/kscreenlockerrc|kde/kscreenlockerrc"
  "$HOME/.config/ksplashrc|kde/ksplashrc"
  "$HOME/.config/kcmfonts|kde/kcmfonts"
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