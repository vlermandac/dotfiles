#!/usr/bin/env bash
set -euo pipefail

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is not installed or not in PATH." >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${HOME}"

packages=()
for dir in "${repo_dir}"/*; do
  [[ -d "${dir}" ]] || continue
  packages+=("$(basename "${dir}")")
done

if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "No packages found in ${repo_dir}." >&2
  exit 1
fi

stow --dir "${repo_dir}" --target "${target_dir}" --delete "${packages[@]}"
echo "Dotfiles unstowed from ${target_dir}."
