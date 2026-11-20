#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-start}"
MEDIA_STACK_HELPER="${HOME}/.config/hypr/scripts/start-media-stack.sh"
TRAY_SESSION_HELPER="${HOME}/.config/hypr/scripts/hypr-tray-session"
IMPORT_RETRY_COUNT=15
IMPORT_RETRY_DELAY=1
SESSION_READY_RETRY_COUNT=30
SESSION_READY_RETRY_DELAY=1
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
LOCK_FILE="${RUNTIME_DIR}/unified-session-bootstrap.lock"

mkdir -p "$RUNTIME_DIR"
exec 9>"$LOCK_FILE"
flock -w 30 9 || {
  echo "timed out waiting for another session bootstrap" >&2
  exit 1
}

add_var() {
  local name="$1"
  local existing

  for existing in "${ENV_VARS[@]}"; do
    if [ "$existing" = "$name" ]; then
      return
    fi
  done

  ENV_VARS+=("$name")
}

resolve_live_hypr_instance() {
  local instances_json active_count
  local resolved_signature=""
  local resolved_wayland=""

  if ! command -v hyprctl >/dev/null 2>&1; then
    return 1
  fi

  instances_json="$(hyprctl instances -j 2>/dev/null || true)"
  if [ -z "$instances_json" ] || [ "$instances_json" = "[]" ]; then
    return 1
  fi

  if ! jq -e . >/dev/null 2>&1 <<<"$instances_json"; then
    return 1
  fi

  active_count="$(jq 'length' <<<"$instances_json")"

  if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    resolved_signature="${HYPRLAND_INSTANCE_SIGNATURE}"
    resolved_wayland="$(jq -r --arg sig "$resolved_signature" '.[] | select(.instance == $sig) | .wl_socket' <<<"$instances_json" | head -n1)"
  fi

  if [ -z "$resolved_wayland" ] && [ -n "${WAYLAND_DISPLAY:-}" ]; then
    resolved_wayland="${WAYLAND_DISPLAY}"
    resolved_signature="$(jq -r --arg socket "$resolved_wayland" '.[] | select(.wl_socket == $socket) | .instance' <<<"$instances_json" | head -n1)"
  fi

  if [ -z "$resolved_wayland" ] && [ "$active_count" -eq 1 ]; then
    resolved_wayland="$(jq -r '.[0].wl_socket' <<<"$instances_json")"
    resolved_signature="$(jq -r '.[0].instance' <<<"$instances_json")"
  fi

  if [ -n "$resolved_wayland" ] && [ "$resolved_wayland" != "null" ]; then
    export WAYLAND_DISPLAY="$resolved_wayland"
  fi

  if [ -n "$resolved_signature" ] && [ "$resolved_signature" != "null" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE="$resolved_signature"
  fi

  [ -n "${WAYLAND_DISPLAY:-}" ] && \
    [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && \
    [ -S "${RUNTIME_DIR}/${WAYLAND_DISPLAY}" ] && \
    [ -S "${RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" ]
}

wait_for_live_hypr_session() {
  local attempt=1

  while [ "$attempt" -le "$SESSION_READY_RETRY_COUNT" ]; do
    if resolve_live_hypr_instance; then
      return 0
    fi

    sleep "$SESSION_READY_RETRY_DELAY"
    attempt=$((attempt + 1))
  done

  echo "Hyprland session sockets were not ready after ${SESSION_READY_RETRY_COUNT} attempts" >&2
  return 1
}

sync_session_environment() {
  local imported_wayland imported_signature live_wayland

  wait_for_live_hypr_session

  export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-Hyprland}"
  export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
  export LANG="${LANG:-en_US.UTF-8}"

  # (AI-assisted) Share credential locations with environment.d and noninteractive Zsh.
  # This file contains paths only; never decrypt pass entries during session startup.
  local credential_environment="${XDG_CONFIG_HOME:-$HOME/.config}/environment.d/60-credential-paths.conf"
  if [[ -r "$credential_environment" ]]; then
    source "$credential_environment"
    export GNUPGHOME PASSWORD_STORE_DIR
  fi

  ENV_VARS=(
    WAYLAND_DISPLAY
    HYPRLAND_INSTANCE_SIGNATURE
    XDG_RUNTIME_DIR
    XDG_CURRENT_DESKTOP
    XDG_SESSION_TYPE
    LANG
  )

  [[ -z "${GNUPGHOME:-}" ]] || add_var GNUPGHOME
  [[ -z "${PASSWORD_STORE_DIR:-}" ]] || add_var PASSWORD_STORE_DIR

  while IFS='=' read -r name _; do
    case "$name" in
      LC_*) add_var "$name" ;;
    esac
  done < <(env)

  if import_user_environment; then
    imported_wayland="$(systemctl --user show-environment | awk -F= '$1 == "WAYLAND_DISPLAY" { print $2 }')"
    imported_signature="$(systemctl --user show-environment | awk -F= '$1 == "HYPRLAND_INSTANCE_SIGNATURE" { print $2 }')"

    if [ "${imported_wayland:-}" != "${WAYLAND_DISPLAY:-}" ]; then
      echo "systemd user environment has WAYLAND_DISPLAY=${imported_wayland:-<unset>} but live session has ${WAYLAND_DISPLAY:-<unset>}" >&2
      return 1
    fi

    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ "${imported_signature:-}" != "${HYPRLAND_INSTANCE_SIGNATURE}" ]; then
      echo "systemd user environment has HYPRLAND_INSTANCE_SIGNATURE=${imported_signature:-<unset>} but live session has ${HYPRLAND_INSTANCE_SIGNATURE}" >&2
      return 1
    fi

    if command -v hyprctl >/dev/null 2>&1 && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      live_wayland="$(hyprctl instances -j 2>/dev/null | jq -r --arg sig "$HYPRLAND_INSTANCE_SIGNATURE" '.[] | select(.instance == $sig) | .wl_socket' | head -n1)"
      if [ -n "${live_wayland:-}" ] && [ "$live_wayland" != "null" ] && [ "$live_wayland" != "${WAYLAND_DISPLAY:-}" ]; then
        echo "live Hyprland instance ${HYPRLAND_INSTANCE_SIGNATURE} is on ${live_wayland}, not ${WAYLAND_DISPLAY:-<unset>}" >&2
        return 1
      fi
    fi
  else
    echo "warning: could not import Hyprland environment into the user bus yet; continuing startup" >&2
  fi
}

import_user_environment() {
  local attempt=1

  while [ "$attempt" -le "$IMPORT_RETRY_COUNT" ]; do
    if dbus-update-activation-environment --systemd "${ENV_VARS[@]}" >/dev/null 2>&1 && \
       systemctl --user import-environment "${ENV_VARS[@]}" >/dev/null 2>&1; then
      return 0
    fi

    sleep "$IMPORT_RETRY_DELAY"
    attempt=$((attempt + 1))
  done

  return 1
}

restart_waybar() {
  sync_session_environment || true

  if systemctl --user reset-failed waybar >/dev/null 2>&1 && systemctl --user restart waybar >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

refresh_bar() {
  sync_session_environment || true

  if systemctl --user cat unified-quickshell.service >/dev/null 2>&1; then
    systemctl --user reset-failed unified-quickshell.service >/dev/null 2>&1 || true
    systemctl --user start unified-quickshell.service >/dev/null 2>&1
    return
  fi

  restart_waybar
}

refresh_herdr_environment() {
  local herdr_pid inherited_wayland

  if ! systemctl --user is-active --quiet herdr-server.service; then
    return
  fi

  herdr_pid="$(systemctl --user show herdr-server.service --property MainPID --value)"
  if [ -z "$herdr_pid" ] || [ "$herdr_pid" = "0" ] || [ ! -r "/proc/$herdr_pid/environ" ]; then
    return
  fi

  inherited_wayland="$(
    tr '\0' '\n' <"/proc/$herdr_pid/environ" |
      sed -n 's/^WAYLAND_DISPLAY=//p' |
      head -n 1
  )"

  if [ -n "${WAYLAND_DISPLAY:-}" ] && [ "$inherited_wayland" != "$WAYLAND_DISPLAY" ]; then
    # Herdr can be pulled in by Collie before Hyprland has created/imported its
    # Wayland environment.  Restart it once during compositor startup so all
    # subsequently created terminals inherit the live Wayland socket.
    systemctl --user restart herdr-server.service
  fi
}

print_status() {
  local imported_wayland imported_signature live_instance live_wayland

  imported_wayland="$(systemctl --user show-environment | awk -F= '$1 == "WAYLAND_DISPLAY" { print $2 }')"
  imported_signature="$(systemctl --user show-environment | awk -F= '$1 == "HYPRLAND_INSTANCE_SIGNATURE" { print $2 }')"

  if command -v hyprctl >/dev/null 2>&1; then
    local instances_json=""
    instances_json="$(hyprctl instances -j 2>/dev/null || true)"
    if jq -e . >/dev/null 2>&1 <<<"$instances_json"; then
      live_instance="$(jq -r 'if length == 1 then .[0].instance else empty end' <<<"$instances_json")"
      live_wayland="$(jq -r 'if length == 1 then .[0].wl_socket else empty end' <<<"$instances_json")"
    fi
  fi

  printf 'LIVE_WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-}"
  printf 'IMPORTED_WAYLAND_DISPLAY=%s\n' "${imported_wayland:-}"
  printf 'LIVE_HYPRLAND_INSTANCE_SIGNATURE=%s\n' "${HYPRLAND_INSTANCE_SIGNATURE:-${live_instance:-}}"
  printf 'IMPORTED_HYPRLAND_INSTANCE_SIGNATURE=%s\n' "${imported_signature:-}"
  printf 'HYPRCTL_WAYLAND_DISPLAY=%s\n' "${live_wayland:-}"
}

start_session() {
  local session_identity session_key session_marker

  sync_session_environment
  session_identity="${HYPRLAND_INSTANCE_SIGNATURE:-unknown}:${WAYLAND_DISPLAY:-unknown}"
  session_key="$(printf '%s' "$session_identity" | sha256sum | cut -c1-32)"
  session_marker="${RUNTIME_DIR}/unified-session-${session_key}.started"

  systemctl --user start waywallen.service
  systemctl --user start unified-quickshell.service

  systemctl --user is-active --quiet waywallen.service
  systemctl --user is-active --quiet unified-quickshell.service

  # (AI-assisted) Bring up the wallpaper and UI before nonvisual session helpers.
  if [ "${UNIFIED_SESSION_SKIP_HERDR_REFRESH:-0}" != "1" ]; then
    refresh_herdr_environment
  fi
  systemctl --user reset-failed clipboard-bridge.service >/dev/null 2>&1 || true
  systemctl --user start clipboard-bridge.service >/dev/null 2>&1 || true

  if [ -e "$session_marker" ]; then
    return
  fi

  hyprctl dispatch workspace 3 >/dev/null 2>&1 || true

  if [ -x "$MEDIA_STACK_HELPER" ]; then
    "$MEDIA_STACK_HELPER" >/dev/null 2>&1 9>&- &
  fi

  # (AI-assisted) The tray helper shows special:tray while it waits for Thunderbird and Telegram, and
  # any window that maps meanwhile lands in the hidden tray. Start the other apps only after it is done.
  (
    if [ -x "$TRAY_SESSION_HELPER" ]; then
      "$TRAY_SESSION_HELPER" ensure >/dev/null 2>&1 || true
    fi

    # Secretary bots' clients: T3 Code (opening it also updates the T3 server after a system update) and Grok Bot.
    # Each runs as its own transient unit so a restart of this bootstrap never takes them down.
    pgrep -x t3code >/dev/null ||
      systemd-run --user --collect --quiet --unit=autostart-t3code /opt/t3code-nightly-bin/t3code >/dev/null 2>&1 || true
    pgrep -x grok-bot >/dev/null ||
      systemd-run --user --collect --quiet --unit=autostart-grok-bot "$HOME/.local/share/grok-bot/appimage" -- >/dev/null 2>&1 || true
  ) 9>&- &

  : >"$session_marker"
}

case "$MODE" in
  start)
    start_session
    ;;
  sync-env)
    sync_session_environment
    ;;
  restart-waybar)
    restart_waybar
    ;;
  refresh-bar)
    refresh_bar
    ;;
  status)
    print_status
    ;;
  *)
    echo "Usage: $0 [start|sync-env|refresh-bar|restart-waybar|status]" >&2
    exit 1
    ;;
esac
