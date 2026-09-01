# ~/.config/zsh/zshrc.d/60-prompt.zsh

if command -v oh-my-posh >/dev/null 2>&1; then
  _oh_my_posh_theme="${XDG_CONFIG_HOME:-$HOME/.config}/ohmyposh/config.toml"
  eval "$(oh-my-posh init zsh --strict --config "$_oh_my_posh_theme")"
  unset _oh_my_posh_theme
else
  print -P "%F{yellow}[zsh]%f oh-my-posh not found. Install it to enable prompt theming."
fi
