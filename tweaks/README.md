# Tweaks

One-off system tweaks, stored mirroring your home-directory layout
(just like the theme folders). To apply a tweak, drag the file from here
onto the matching path on your PC — the folder structure below `tweaks/`
corresponds 1:1 to your home directory.

## reapply-darkmode → terminal-browser

- **Repo path:** `tweaks/.local/bin/reapply-darkmode`
- **Apply to:** `~/.local/bin/reapply-darkmode` (keep it executable)
- **What it does:** re-applies a patch to terminal-browser
  (`zenbu-labs`, installed under `~/.local/share/terminal-browser/app/`)
  that makes every site render in dark mode. It patches
  `browser/dist/main.js` so `emulateColorScheme()` always sends
  `prefers-color-scheme: dark` **and** enables Chromium's
  `Emulation.setAutoDarkModeOverride` (dark-capable sites use their dark
  theme; light-only sites get auto-darkened). The bundled `main.js` is
  overwritten on every `terminal-browser upgrade`, hence the script.

### Notes

- Run `reapply-darkmode` **after** each `terminal-browser upgrade`:
  ```bash
  terminal-browser upgrade
  reapply-darkmode
  ```
- Idempotent — safe to run repeatedly (prints *"already patched"* when done).
- To undo, reinstall/re-upgrade terminal-browser and skip the reapply, or
  edit the patched `emulateColorScheme()` block back to the original.

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