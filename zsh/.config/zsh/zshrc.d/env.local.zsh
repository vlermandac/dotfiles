# ~/.config/zsh/zshrc.d/env.local.zsh
# chmod 600 ~/.config/zsh/zshrc.d/env.local.zsh

# Load secrets from pass only if available
if command -v pass >/dev/null 2>&1; then
  # Example entries:
  #   pass insert api/openai

  OPENAI_API_KEY="$(pass show api/openai 2>/dev/null | head -n1)"

  [[ -n "$OPENAI_API_KEY" ]] && export OPENAI_API_KEY
fi
