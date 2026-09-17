#!/usr/bin/env bash
set -euo pipefail

# Centered Start Menu
# Source package location
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_ID="com.github.centeredstart"
CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

echo "==> Installing '$APP_ID' plasmoid..."

kpackagetool6 -t Plasma/Applet -i "$SRC_DIR" 2>/dev/null \
    || kpackagetool6 -t Plasma/Applet -u "$SRC_DIR"

echo "==> Triggering plasma shell reload so the widget appears in 'Add Widgets'..."
if command -v plasmashell >/dev/null 2>&1; then
    plasmashell --replace &>/dev/null &
    disown || true
fi

echo "==> Done. Add the 'Centered Start Menu' widget from the panel's 'Add Widgets'
    (right-click panel -> Enter Edit Mode -> Add Widgets) to have it appear next to
    your current start menu icon.

NOTE: this script only installs the widget files. Removing the widget from the
panel is done via the normal right-click 'Remove'. To delete ALL traces, run:

    bash $SRC_DIR/remove.sh
"