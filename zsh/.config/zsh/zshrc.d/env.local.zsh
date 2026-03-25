# ~/.config/zsh/rc.d/env.local.zsh
# chmod 600 ~/.config/zsh/rc.d/env.local.zsh

# Load secrets from pass only if available
if command -v pass >/dev/null 2>&1; then
  # Example entries:
  #   pass insert api/openai
  #   pass insert api/deepl

  OPENAI_API_KEY="$(pass show api/openai 2>/dev/null | head -n1)"
  DEEPL_AUTH_KEY="$(pass show api/deepl 2>/dev/null | head -n1)"

  [[ -n "$OPENAI_API_KEY" ]] && export OPENAI_API_KEY
  [[ -n "$DEEPL_AUTH_KEY" ]] && export DEEPL_AUTH_KEY
fi
