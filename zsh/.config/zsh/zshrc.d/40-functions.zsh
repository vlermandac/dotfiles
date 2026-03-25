# ~/.config/zsh/zshrc.d/40-functions.zsh

timezsh() {
  local shell="${1:-$SHELL}"
  local i
  for i in {1..10}; do
    /usr/bin/time "$shell" -i -c exit
  done
}

profzsh() {
  time ZSH_DEBUGRC=1 zsh -i -c exit
}

# Reload shell config
reload() {
  source "$ZDOTDIR/.zshrc"
}

# Rebuild completion dump if needed
recomp() {
  rm -f "$XDG_CACHE_HOME"/zsh/zcompdump-*
  autoload -Uz compinit
  compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
}

# Show exported vars matching a pattern
showenv() {
  if [[ -z "$1" ]]; then
    export | sort
  else
    export | sort | grep -i -- "$1"
  fi
}
