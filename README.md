# dotfiles

Theme configs and one-off tweaks for my Arch/KDE setup.

## Layout

Every theme occupies its own folder at the repo root (`bwzs/`,
`tokyonight-moon/`, `nord/` — `nord` not created yet). Instead of one raw
`.config`/`.local` mirror, each theme is split into **component folders**
(named after the app/system that owns the config). The path *below* the
component keeps the home-directory layout, so applying is always a clean
drag-and-drop:

```
~/.config/kitty/kitty.conf          -> bwzs/kitty/.config/kitty/kitty.conf
~/.config/kdeglobals                -> bwzs/kde/.config/kdeglobals
~/.config/plasma-org.kde…appletsrc  -> bwzs/plasma/.config/plasma-org.kde…appletsrc
~/.local/share/plasma/desktoptheme  -> bwzs/plasma/.local/share/plasma/desktoptheme
~/.local/share/wallpapers           -> bwzs/wallpapers/.local/share/wallpapers
~/.local/share/aurorae              -> bwzs/aurorae/.local/share/aurorae
~/.local/share/color-schemes        -> bwzs/colorschemes/.local/share/color-schemes
~/.spicetify/Themes                 -> bwzs/spicetify/.spicetify/Themes
~/.config/spicetify/config-xpui.ini -> bwzs/spicetify/.config/spicetify/config-xpui.ini
~/.gtkrc-2.0                        -> bwzs/gtk/.gtkrc-2.0
```

### Components

| Component | Contents |
|---|---|
| `alacritty` | `~/.config/alacritty` |
| `aurorae` | `~/.local/share/aurorae` (window decorations) |
| `colorschemes` | `~/.local/share/color-schemes` |
| `fastfetch` | `~/.config/fastfetch` |
| `fish` | `~/.config/fish` |
| `gtk` | `~/.config/gtk-3.0`, `~/.config/gtk-4.0`, `~/.gtkrc-2.0` |
| `kde` | loose KDE config files in `~/.config` (kdeglobals, kwinrc, …) |
| `kitty` | `~/.config/kitty` |
| `mpv` | `~/.var/app/io.mpv.Mpv/config/mpv` (Flatpak) |
| `nvim` | `~/.config/nvim` |
| `oh-my-posh` | `~/.config/oh-my-posh` |
| `plasma` | plasma runtime config (`~/.config/plasma-*rc`, `~/.config/plasmarc`, `~/.config/plasmashellrc`) + `~/.local/share/plasma` (desktoptheme, look-and-feel, plasmoids) |
| `spicetify` | `~/.spicetify` + `~/.config/spicetify` |
| `wallpapers` | `~/.local/share/wallpapers` |

## Syncing

`./backup.sh [theme]` copies the matching `$HOME` paths into the selected
theme folder (via the component mapping above), then commits & pushes.
`rsync --delete` keeps the repo mirror exact. Default theme is `bwzs`.

## Tweaks

One-off tweaks live in `tweaks/<name>/`, each documented in
[tweaks/README.md](tweaks/README.md).

## Notes

- `nord/` doesn't exist yet — `./backup.sh nord` creates it on first run.
- Spicetify-generated files (binary, tokens, states) are git-ignored.
- Nothing sensitive is tracked here; KDE session/activity/wallet state is
  deliberately excluded from the sync pairs.