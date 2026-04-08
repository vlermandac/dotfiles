# ~/.config/zsh/zshrc.d/20-completion.zsh

# Completion paths
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

if [[ -d /usr/local/share/zsh/site-functions ]]; then
  fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# Linux common paths
if [[ -d /usr/share/zsh/site-functions ]]; then
  fpath=(/usr/share/zsh/site-functions $fpath)
fi

if [[ -d /usr/share/zsh/vendor-completions ]]; then
  fpath=(/usr/share/zsh/vendor-completions $fpath)
fi

# Extra completion dirs if installed
if [[ -d /opt/homebrew/share/zsh-completions ]]; then
  fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi

if [[ -d /usr/local/share/zsh-completions ]]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

if [[ -d /usr/share/zsh-completions ]]; then
  fpath=(/usr/share/zsh-completions $fpath)
fi

zmodload -i zsh/complist
autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# official uv / uvx completion
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

if command -v uv >/dev/null 2>&1; then
  eval "$(uvx --generate-shell-completion zsh)"
fi

# custom workaround for: uv run <python-file>
_uv_run_mod() {
  if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
    _arguments '*:filename:_files'
  else
    _uv "$@"
  fi
}

(( $+functions[_uv] && $+functions[compdef] )) && compdef _uv_run_mod uv

# menu behavior
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# matching:
# - case insensitive
# - partial / substring-like matching
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'r:|=*' \
  'l:|=* r:|=*'

# Nice completion for directories
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true

# Process list with ps for kill completion
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
