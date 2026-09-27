# Enable vi mode
bindkey -v

# Faster mode switching (very important)
KEYTIMEOUT=1

# History search (works in both modes)
bindkey -M viins '^[[A' up-line-or-search
bindkey -M viins '^[[B' down-line-or-search
bindkey -M vicmd '^[[A' up-line-or-search
bindkey -M vicmd '^[[B' down-line-or-search

# Basic navigation improvements
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line

# Fix backspace
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# Optional: quick escape from insert mode
bindkey -M viins 'jk' vi-cmd-mode

function _copy_zle_cutbuffer_to_clipboard {
  if [[ -n $CUTBUFFER ]] && command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "${CUTBUFFER%$'\n'}" | wl-copy
  fi
}

function vi-yank-clipboard {
  zle .vi-yank
  _copy_zle_cutbuffer_to_clipboard
}
zle -N vi-yank-clipboard

function vi-yank-whole-line-clipboard {
  zle .vi-yank-whole-line
  _copy_zle_cutbuffer_to_clipboard
}
zle -N vi-yank-whole-line-clipboard

bindkey -M vicmd 'y' vi-yank-clipboard
bindkey -M vicmd 'Y' vi-yank-whole-line-clipboard

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[1 q'  # block cursor
  else
    echo -ne '\e[5 q'  # beam cursor
  fi
}
zle -N zle-keymap-select

function zle-line-init {
  zle -K viins
  echo -ne '\e[5 q'
}
zle -N zle-line-init
