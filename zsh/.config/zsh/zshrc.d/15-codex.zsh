# XDG-style Codex account homes. The plain `codex` command uses `work`;
# `codex-alt` keeps a separate ChatGPT login with copied sessions/config.
export CODEX_HOME="$HOME/.config/codex/accounts/work"

alias codex-work='CODEX_HOME="$HOME/.config/codex/accounts/work" codex'
alias codex-alt='CODEX_HOME="$HOME/.config/codex/accounts/alt" codex'
alias codex-alt-login='CODEX_HOME="$HOME/.config/codex/accounts/alt" codex login --device-auth'
alias codex-alt-status='CODEX_HOME="$HOME/.config/codex/accounts/alt" codex login status'
