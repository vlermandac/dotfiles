# ~/.config/zsh/.zshenv
[[ "$ZDOTDIR" != "$HOME/.config/zsh" ]] && export ZDOTDIR="$HOME/.config/zsh"

# Keep zsh dotfiles under XDG config.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
