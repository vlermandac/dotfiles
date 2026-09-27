# ~/.config/zsh/rc.d/10-env.zsh

# (AI-assisted) Applies to new shells inside long-running Herdr sessions too.
export BROWSER="open-personal-link"

# Ensure XDG directories exist
mkdir -p \
  "$XDG_CACHE_HOME/zsh" \
  "$XDG_STATE_HOME/zsh"

# Long-lived user services such as Herdr can start just before Hyprland has
# imported its session environment.  Recover the live Wayland socket for any
# interactive shell they create instead of letting GUI-aware tools fall back to
# X11.  The user manager is populated by session-bootstrap.sh and is the
# authoritative source for this session.
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" && -z "${WAYLAND_DISPLAY:-}" ]] && \
   command -v systemctl >/dev/null 2>&1; then
  _session_wayland_display="$(
    systemctl --user show-environment 2>/dev/null |
      sed -n 's/^WAYLAND_DISPLAY=//p' |
      head -n 1
  )"

  if [[ -n "$_session_wayland_display" && \
        -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$_session_wayland_display" ]]; then
    export WAYLAND_DISPLAY="$_session_wayland_display"
  fi

  unset _session_wayland_display
fi

# An empty DISPLAY is not a usable X11 endpoint.  Do not export it and tempt
# libraries to select an X11 fallback in an otherwise Wayland-only session.
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" && -z "${DISPLAY:-}" ]]; then
  unset DISPLAY
fi

DATE() {
  date "+%A, %B %e  %_I:%M%P"
}

# Keep global npm packages user-owned and outside pacman's /usr tree.
export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-$XDG_DATA_HOME/npm}"

# PATH
path=(
  "$HOME/.local/bin"
  "$NPM_CONFIG_PREFIX/bin"
  "$PNPM_HOME/bin"
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
