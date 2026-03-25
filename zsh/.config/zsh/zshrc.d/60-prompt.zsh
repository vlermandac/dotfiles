# ~/.config/zsh/zshrc.d/60-prompt.zsh

if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config "$XDG_CONFIG_HOME/ohmyposh/theme.toml")"
else
  print -P "%F{yellow}[zsh]%f oh-my-posh not found. Install it to enable prompt theming."
fi
