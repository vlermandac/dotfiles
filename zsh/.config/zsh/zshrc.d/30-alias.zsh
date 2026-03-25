# ~/.config/zsh/zshrc.d/30-aliases.zsh

alias vim='nvim'
alias cd='z'
alias tree='tree -C --gitignore'
alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'

# safer/common variants
alias ls='ls --color=auto 2>/dev/null || ls -G'
alias ll='ls -lh'
alias la='ls -lah'
