#!/usr/bin/env bash
set -euo pipefail

# Centered Start Menu - complete removal (no traces)
APP_ID="com.github.centeredstart"
APP_DIR="$HOME/.local/share/plasma/plasmoids/$APP_ID"
CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

echo "==> Removing '$APP_ID'..."

# 1. Uninstall the plasmoid package entirely
kpackagetool6 -t Plasma/Applet -r "$APP_ID" 2>/dev/null || true

# 2. Also nuke any leftover manually-placed folder
rm -rf "$APP_DIR"

# 3. Strip all traces from the plasma panel config
if [ -f "$CONFIG" ]; then
    python3 - "$CONFIG" "$APP_ID" <<'PYEOF'
import re, sys

path, appid = sys.argv[1], sys.argv[2]

with open(path) as f:
    lines = f.read().splitlines()

# Find numeric applet ids that use our plugin.
applet_root_re = re.compile(r"^\[Containments\]\[[0-9]+\]\[Applets\]\[([0-9]+)\]$")
plugin_ids = set()
current_root = None
for line in lines:
    m = applet_root_re.match(line)
    if m:
        current_root = m.group(1)
        continue
    if line.startswith("[") and not line.startswith("[Containments]"):
        current_root = None
    if current_root and line == "plugin=" + appid:
        plugin_ids.add(current_root)
        current_root = None

# Classify every section by its applet id and drop those that belong to ids.
any_section_re = re.compile(r"^\[Containments\]\[[0-9]+\]\[Applets\]\[([0-9]+)\]($|\])")

out = []
skip = False
for line in lines:
    if line.startswith("["):
        m = any_section_re.match(line)
        skip = bool(m and m.group(1) in plugin_ids)
    if not skip:
        out.append(line)

# Remove leftover empty lines caused by deletion.
text = "\n".join(out)
text = re.sub(r"\n{3,}", "\n\n", text)

# Remove the ids from AppletOrder lines.
text = re.sub(r"(?m)^AppletOrder=(?P<lst>[^\n]+)$",
              lambda m: "AppletOrder=" + ";".join(
                  x for x in m.group("lst").split(";") if x not in plugin_ids),
              text)

with open(path, "w") as f:
    f.write(text)

print("   stripped applet ids from panel config:", sorted(plugin_ids) or "none")
PYEOF
fi

# 4. Refresh the shell so it forgets the widget
if command -v plasmashell >/dev/null 2>&1; then
    plasmashell --replace &>/dev/null &
    disown || true
fi

echo "==> Done. All traces of '$APP_ID' have been removed."