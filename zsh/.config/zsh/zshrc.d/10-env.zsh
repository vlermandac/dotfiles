# ~/.config/zsh/rc.d/10-env.zsh

# Ensure XDG directories exist
mkdir -p \
  "$XDG_CACHE_HOME/zsh" \
  "$XDG_STATE_HOME/zsh"

DATE() {
  date "+%A, %B %e  %_I:%M%P"
}

# PATH
path=(
  "$HOME/.local/bin"
  "$NPM_CONFIG_PREFIX/bin"
  "$CARGO_HOME/bin"
  "$GOBIN"
  $path
)
export PATH

# Colors
autoload -Uz colors && colors
eval "$(dircolors -b)"

# Tool init
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Kitty manual shell integration
if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
  export KITTY_SHELL_INTEGRATION="enabled"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

# Local machine-specific env and secrets
[[ -f "$ZDOTDIR/zshrc.d/env.local.zsh" ]] && source "$ZDOTDIR/zshrc.d/env.local.zsh"
