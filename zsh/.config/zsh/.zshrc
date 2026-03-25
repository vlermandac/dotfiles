# ~/.config/zsh/.zshrc

# Zsh profiler
if [[ -n "${ZSH_DEBUGRC+1}" ]]; then
  zmodload zsh/zprof
fi

# Load modular config
for file in "$ZDOTDIR"/zshrc.d/*.zsh(N); do
  source "$file"
done

if [[ -n "${ZSH_DEBUGRC+1}" ]]; then
  zprof
fi
