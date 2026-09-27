# XDG base directories are optional environment variables. Define their
# standard defaults before any Zsh startup module uses them, while preserving
# deliberate overrides inherited from the parent process.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# (AI-assisted) Same non-secret credential paths as systemd and desktop bootstrap.
if [[ -r "$XDG_CONFIG_HOME/environment.d/60-credential-paths.conf" ]]; then
    source "$XDG_CONFIG_HOME/environment.d/60-credential-paths.conf"
    export GNUPGHOME PASSWORD_STORE_DIR
fi

# Package-manager locations must also be available to non-interactive Zsh
# processes, which do not read .zprofile or .zshrc.
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Keep CLI/agent path resolution aligned with GUI user services.
if [[ -r "$XDG_CONFIG_HOME/environment.d/70-xdg-app-paths.conf" ]]; then
    source "$XDG_CONFIG_HOME/environment.d/70-xdg-app-paths.conf"
    export RUSTUP_HOME CUDA_CACHE_PATH IMPECCABLE_HOME
    export IMPECCABLE_UPDATE_CACHE IMPECCABLE_STALENESS_CACHE IMPECCABLE_CACHE_ROOT
fi

export BUN_INSTALL_CACHE_DIR="$XDG_CACHE_HOME/bun/install/cache"
export BUN_INSTALL_GLOBAL_DIR="$XDG_DATA_HOME/bun/install/global"
export BUN_INSTALL_BIN="$HOME/.local/bin"
export BUN_RUNTIME_TRANSPILER_CACHE_PATH="$XDG_CACHE_HOME/bun/runtime-transpiler"

export CLAUDE_CONFIG_DIR=/home/vlermanda/.config/claude
export LOGFIRE_CREDENTIALS_DIR=/home/vlermanda/.config/logfire
