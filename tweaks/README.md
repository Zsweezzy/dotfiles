# Tweaks

One-off system tweaks, stored mirroring your home-directory layout
(just like the theme folders). To apply a tweak, drag the file from here
onto the matching path on your PC — the folder structure below `tweaks/`
corresponds 1:1 to your home directory.

## cachy-update → kitty

- **Repo path:** `tweaks/.local/share/applications/arch-update.desktop`
- **Apply to:** `~/.local/share/applications/arch-update.desktop`
- **What it does:** makes Cachy-Update run inside kitty instead of
  Konsole. The system file `/usr/share/applications/arch-update.desktop`
  uses `Terminal=true` (so the DE picks the default terminal = Konsole);
  this user-level override sets `Terminal=false` and
  `Exec=kitty -e arch-update` instead. Because it lives in
  `~/.local/share/applications/`, it shadows the system entry and
  survives package updates — no need to edit the packaged file.

### Notes

- After dropping the file in place, refresh the app menu (KDE):
  `kbuildsycoca6`
- If the systray applet was already running, restart it so it picks up
  the newer file:
  `systemctl --user restart 'app-arch\x2dupdate\x2dtray@autostart.service'`
- Delete the file (or the whole `tweaks/` folder) to undo the tweak.