#!/usr/bin/env bash
set -euo pipefail

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is not installed or not in PATH." >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${HOME}"
packages=(btop environment gh git herdr kitty mpv npm nvim paru sioyek thunar tree-sitter yazi yt-dlp zsh)
stow_ignore='^([.]zprofile|[.]zshenv|[.]zshrc|zshrc[.]d)(/|$)|(^|/)(hosts[.]yml|env[.]local[.]zsh)$|[.](bak(-.*)?|before-.*|tmp|orig)$'

stow \
  --no-folding \
  --ignore "${stow_ignore}" \
  --dir "${repo_dir}" \
  --target "${target_dir}" \
  --delete "${packages[@]}"
echo "Dotfiles unstowed from ${target_dir}."
