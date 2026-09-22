#!/usr/bin/env bash
# backup.sh — sync theme dotfiles into this repo, then commit & push.
# Every theme lives in its own folder at the repo root, split into named
# *component* folders (the app/system owning the config). The path below
# the component keeps the home-directory layout, e.g.
#   ~/.config/kitty/kitty.conf      -> bwzs/kitty/.config/kitty/kitty.conf
#   ~/.local/share/plasma/desktoptheme -> bwzs/plasma/.local/share/plasma/…
# Usage: ./backup.sh [theme]   (defaults to "bwzs"; e.g. ./backup.sh nord)
# Run me after you tweak a theme; safe to run repeatedly.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

THEME="${1:-bwzs}"

# "source path|repo-relative destination"
PAIRS=(
  # Terminal
  "$HOME/.config/oh-my-posh|oh-my-posh/.config/oh-my-posh"
  "$HOME/.config/fastfetch|fastfetch/.config/fastfetch"
  "$HOME/.config/fish|fish/.config/fish"
  "$HOME/.config/kitty|kitty/.config/kitty"
  "$HOME/.config/alacritty|alacritty/.config/alacritty"

  # GTK
  "$HOME/.config/gtk-3.0|gtk/.config/gtk-3.0"
  "$HOME/.config/gtk-4.0|gtk/.config/gtk-4.0"
  "$HOME/.gtkrc-2.0|gtk/.gtkrc-2.0"

  # Editors / apps
  "$HOME/.config/nvim|nvim/.config/nvim"

  # mpv (Flatpak) — YouTube-style OSC + Tokyo Night Moon colors
  "$HOME/.var/app/io.mpv.Mpv/config/mpv|mpv/.var/app/io.mpv.Mpv/config/mpv"

  # Spicetify (user content only — Themes, Extensions, CustomApps,
  # plus the spicetify-cli config & active theme)
  "$HOME/.spicetify/Themes|spicetify/.spicetify/Themes"
  "$HOME/.spicetify/Extensions|spicetify/.spicetify/Extensions"
  "$HOME/.spicetify/CustomApps|spicetify/.spicetify/CustomApps"
  "$HOME/.config/spicetify/Themes|spicetify/.config/spicetify/Themes"
  "$HOME/.config/spicetify/config-xpui.ini|spicetify/.config/spicetify/config-xpui.ini"

  # KDE Plasma theme
  "$HOME/.local/share/plasma/desktoptheme|plasma/.local/share/plasma/desktoptheme"
  "$HOME/.local/share/plasma/look-and-feel|plasma/.local/share/plasma/look-and-feel"
  "$HOME/.local/share/plasma/plasmoids|plasma/.local/share/plasma/plasmoids"
  "$HOME/.local/share/plasma/wallpapers|plasma/.local/share/plasma/wallpapers"
  "$HOME/.local/share/color-schemes|colorschemes/.local/share/color-schemes"
  "$HOME/.local/share/aurorae|aurorae/.local/share/aurorae"
  "$HOME/.local/share/wallpapers|wallpapers/.local/share/wallpapers"

  # KDE config (theme/layout only — no activity history, wallets, or session state)
  "$HOME/.config/kdeglobals|kde/.config/kdeglobals"
  "$HOME/.config/kwinrc|kde/.config/kwinrc"
  "$HOME/.config/kwinrulesrc|kde/.config/kwinrulesrc"
  "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc|plasma/.config/plasma-org.kde.plasma.desktop-appletsrc"
  "$HOME/.config/plasmashellrc|plasma/.config/plasmashellrc"
  "$HOME/.config/plasmarc|plasma/.config/plasmarc"
  "$HOME/.config/kscreenlockerrc|kde/.config/kscreenlockerrc"
  "$HOME/.config/ksplashrc|kde/.config/ksplashrc"
  "$HOME/.config/kcmfonts|kde/.config/kcmfonts"
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