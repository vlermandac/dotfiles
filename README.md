# Dotfiles

Managed with GNU Stow and organized for XDG (`~/.config/...`) targets.

## Layout

Each top-level directory is a Stow package:

- `btop` -> btop preferences (generated palette excluded)
- `environment` -> shared XDG, language-manager, and cache paths
- `gh` -> `~/.config/gh`
- `git` -> Git identity and global ignore patterns
- `herdr` -> terminal, keybindings, worktree location, and theme preferences
- `kitty` -> `~/.config/kitty`
- `mpv` -> `~/.config/mpv`
- `npm` -> user-owned install prefix and cache location
- `nvim` -> `~/.config/nvim`
- `paru` -> AUR review/security-gate configuration
- `sioyek` -> keyboard and PDF-filter overrides (generated preferences excluded)
- `thunar` -> custom actions and keyboard accelerators
- `tree-sitter` -> `~/.config/tree-sitter`
- `yazi` -> openers, navigation, plugin manifest, and two local plugins
- `yt-dlp` -> `~/.config/yt-dlp`
- `zsh` -> `~/.config/zsh` (`ZDOTDIR` is set centrally in `/etc/zsh/zshenv`)

The installer deliberately ignores the package-root `.zprofile`, `.zshenv`,
`.zshrc`, and `zshrc.d` compatibility links so that the top level of `$HOME`
does not gain symlinks.

## Install

```bash
./install.sh
```

`install.sh` backs up any conflicting existing files from `$HOME` into:

`$XDG_STATE_HOME/dotfiles/backups/<timestamp>/...`

This gives priority to the files in this repository, as requested.

Files are linked individually (`--no-folding`) so application-generated files
can coexist without being written into the repository. Existing directory
links from older installations may remain.

## Ownership and local dependencies

Unified Quickshell, QuickDSH, their deployment files, generated Matugen palettes,
credentials, browser profiles, plugin caches, and runtime state are excluded.
In particular, environment.d/60-credential-paths.conf and
65-personal-browser.conf remain owned by Unified Quickshell. GitHub hosts.yml
and Zsh env.local.zsh remain local and ignored; configure credentials separately.

This is the current user's desktop configuration, not a portable distro preset:
some files retain absolute local paths. Review them before installing elsewhere.
Paru expects the existing `paru-security-gate` and local Sioyek package overlay;
Yazi expects `pdf-open` (Zathura), ripdrag, imv-wayland, mpv, wl-copy and ImageMagick.
Those helpers retain their current owners and are not copied here.
PDF reading uses the user-installed `org.pwmt.zathura` Flatpak with original
document colors. Sioyek is retired; see `docs/PDF_READER.md`.
Install Yazi's upstream plugins from its manifest with `ya pkg install`.
The local drag and image-clipboard plugins are retained as installed.
Dynamic themes are supplied by the separate Matugen integration.

After editing environment.d, new user services/login sessions receive its
values; already-running processes retain their previous environment.

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
