# ~/.config/zsh/zshrc.d/00-options.zsh

# History
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_STATE_HOME/zsh/history"

# Shell behavior
setopt AUTO_CD
setopt AUTO_MENU
setopt ALWAYS_TO_END
setopt COMPLETE_IN_WORD
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt NO_FLOW_CONTROL
setopt PROMPT_SUBST

unsetopt MENU_COMPLETE

# Make Ctrl-S not freeze the terminal
stty stop undef 2>/dev/null
