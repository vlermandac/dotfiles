#!/usr/bin/env bash
set -euo pipefail

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is not installed or not in PATH." >&2
  echo "Install it first (macOS: brew install stow)." >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${HOME}"

discover_packages() {
  local dir name
  local -a found=()
  for dir in "${repo_dir}"/*; do
    [[ -d "${dir}" ]] || continue
    name="$(basename "${dir}")"
    found+=("${name}")
  done
  printf '%s\n' "${found[@]}"
}

mapfile -t packages < <(discover_packages)

if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "No packages found in ${repo_dir}." >&2
  exit 1
fi

backup_root="${HOME}/.dotfiles-backup"
backup_dir="${backup_root}/$(date +%Y%m%d-%H%M%S)"
made_backup=0

backup_conflicts_for_package() {
  local package="$1"
  local package_dir="${repo_dir}/${package}"
  local src rel dst bkp

  while IFS= read -r -d '' src; do
    rel="${src#${package_dir}/}"
    dst="${target_dir}/${rel}"

    [[ -e "${dst}" || -L "${dst}" ]] || continue

    # Keep already-correct symlinks.
    if [[ -L "${dst}" ]]; then
      local current_link
      current_link="$(readlink "${dst}")"
      if [[ "${current_link}" == "${src}" ]]; then
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
stow --dir "${repo_dir}" --target "${target_dir}" --restow "${packages[@]}"

echo "Done."
