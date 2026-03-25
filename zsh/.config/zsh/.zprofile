#!/bin/sh
# env vars to set on login

# warn if ZDOTDIR is not correctly set
if [ "$ZDOTDIR" != "$HOME/.config/zsh" ]; then
  if [ -z "$ZSH_ZDOTDIR_WARNED" ]; then
    export ZSH_ZDOTDIR_WARNED=1
    echo "[zsh] ZDOTDIR is not set to ~/.config/zsh."
    echo "[zsh] Consider adding 'export ZDOTDIR=\"$HOME/.config/zsh\"' to /etc/zsh/zshenv"
  fi
fi

# default programs
export EDITOR="nvim"
export TERM="kitty"
export TERMINAL="kitty"
export MUSPLAYER=""
export BROWSER="brave"
export BROWSER2=""

export XDG_RUNTIME_DIR="/run/user/$UID"

# history files
export LESSHISTFILE="$XDG_CACHE_HOME/less_history"
export PYTHON_HISTORY="$XDG_DATA_HOME/python/history"

# moving other files and some other vars
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$GOPATH/bin"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"
export _JAVA_AWT_WM_NONREPARENTING=1
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter
export FFMPEG_DATADIR="$XDG_CONFIG_HOME/ffmpeg"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export CC=gcc
export CXX=g++

export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 30% --preview='bat -p --color=always {}'"
export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview" # separate opts for history widget
export MANPAGER="less -R --use-color -Dd+r -Du+b" # colored man pages

# colored less + termcap vars
export LESS="R --use-color -Dd+r -Du+b"
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"
