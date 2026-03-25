# Dotfiles

Managed with GNU Stow and organized for XDG (`~/.config/...`) targets.

## Layout

Each top-level directory is a Stow package:

- `gh` -> `~/.config/gh`
- `kitty` -> `~/.config/kitty`
- `mpv` -> `~/.config/mpv`
- `nvim` -> `~/.config/nvim`
- `tree-sitter` -> `~/.config/tree-sitter`
- `yt-dlp` -> `~/.config/yt-dlp`
- `zsh` -> `~/.config/zsh` + `~/.zshenv` (required for XDG `ZDOTDIR` bootstrap)

## Install

```bash
./install.sh
```

`install.sh` backs up any conflicting existing files from `$HOME` into:

`~/.dotfiles-backup/<timestamp>/...`

This gives priority to the files in this repository, as requested.

## Uninstall

```bash
./uninstall.sh
```

## GitHub

```bash
git init
git add .
git commit -m "Initial stow-managed XDG dotfiles"
# then connect your remote and push:
# git remote add origin <your-repo-url>
# git push -u origin main
```
