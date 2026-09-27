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

# Load a pass-backed API key only when this shell actually needs it.
load-api-key() {
  local key_name="$1"
  local env_var service_name entry value

  if [[ -z "$key_name" ]]; then
    echo "usage: load-api-key KEY_NAME" >&2
    return 1
  fi

  if [[ "$key_name" == "${(U)key_name}" && "$key_name" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
    env_var="$key_name"
  else
    env_var="$(printf '%s' "$key_name" | tr '[:lower:].-' '[:upper:]__')_API_KEY"
  fi

  if [[ ! "$env_var" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
    echo "error: KEY_NAME must resolve to a shell variable, e.g. DEEPL_API_KEY" >&2
    return 1
  fi

  service_name="${env_var:l}"
  service_name="${service_name%_api_key}"
  service_name="${service_name%_token}"
  entry="api/$service_name"

  value="$(pass show "$entry" 2>/dev/null | head -n1)" || {
    echo "error: missing pass entry: $entry" >&2
    return 1
  }

  if [[ -z "$value" ]]; then
    echo "error: empty pass entry: $entry" >&2
    return 1
  fi

  export "$env_var=$value"
  echo "$env_var loaded from $entry"
}

# Add an API key to pass and load the resulting env var into this shell only.
add-api-key() {
  "$HOME/.local/bin/add-api-key" "$@" || return
  load-api-key "$1"
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
