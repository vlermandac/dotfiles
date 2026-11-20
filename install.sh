#!/usr/bin/env bash
set -euo pipefail

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is not installed or not in PATH." >&2
  echo "On CachyOS/Arch: sudo pacman -S --needed stow" >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${HOME}"
packages=(btop environment gh git herdr hypr kitty mpv npm nvim paru sioyek thunar tree-sitter yazi yt-dlp zsh)

# ZDOTDIR is set by /etc/zsh/zshenv, so only ~/.config/zsh is needed.
# Ignoring these package-root compatibility links keeps $HOME symlink-free.
stow_ignore='^([.]zprofile|[.]zshenv|[.]zshrc|zshrc[.]d)(/|$)|(^|/)(hosts[.]yml|env[.]local[.]zsh)$|[.](bak(-.*)?|before-.*|tmp|orig)$'

state_home="${XDG_STATE_HOME:-${HOME}/.local/state}"
backup_root="${state_home}/dotfiles/backups"
backup_dir="${backup_root}/$(date +%Y%m%d-%H%M%S)"
made_backup=0

backup_conflicts_for_package() {
  local package="$1"
  local package_dir="${repo_dir}/${package}"
  local src rel dst bkp

  while IFS= read -r -d '' src; do
    rel="${src#${package_dir}/}"
    # Local account files and backups must never be moved by the installer.
    case "$rel" in
      */hosts.yml|*/env.local.zsh|*.bak|*.bak-*|*.before-*|*.tmp|*.orig) continue ;;
    esac
    dst="${target_dir}/${rel}"

    [[ -e "${dst}" || -L "${dst}" ]] || continue

    # A Stow link may exist on any parent directory, so dst itself can look
    # like a regular file while still resolving to this exact source file.
    # Treat identical resolved objects as already installed.
    if [[ -e "${src}" && -e "${dst}" ]]; then
      if [[ "$(realpath -e "${dst}")" == "$(realpath -e "${src}")" ]]; then
        continue
      fi
    fi

    # Keep already-correct symlinks.
    if [[ -L "${dst}" ]]; then
      local current_link current_target
      current_link="$(readlink "${dst}")"
      if [[ "${current_link}" = /* ]]; then
        current_target="$(realpath -m "${current_link}")"
      else
        current_target="$(realpath -m "$(dirname "${dst}")/${current_link}")"
      fi
      if [[ "${current_target}" == "$(realpath -m "${src}")" ]]; then
        continue
      fi
    fi

    # Directory-to-directory is fine; stow can merge trees.
    if [[ -d "${dst}" && -d "${src}" && ! -L "${dst}" ]]; then
      continue
    fi

    if [[ "${made_backup}" -eq 0 ]]; then
      mkdir -p "${backup_dir}"
      made_backup=1
    fi

    bkp="${backup_dir}/${rel}"
    mkdir -p "$(dirname "${bkp}")"
    mv "${dst}" "${bkp}"
    echo "Backed up conflict: ${dst} -> ${bkp}"
  done < <(find "${package_dir}" -mindepth 1 -print0)
}

echo "Scanning for conflicts in ${target_dir} ..."
for package in "${packages[@]}"; do
  backup_conflicts_for_package "${package}"
done

if [[ "${made_backup}" -eq 1 ]]; then
  echo "Conflicts were backed up to: ${backup_dir}"
else
  echo "No conflicts found."
fi

echo "Stowing packages into ${target_dir} ..."
stow \
  --no-folding \
  --ignore "${stow_ignore}" \
  --dir "${repo_dir}" \
  --target "${target_dir}" \
  --restow "${packages[@]}"

echo "Done."
