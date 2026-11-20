# Desktop session packages

(AI-assisted) 2026-11-20.

- `hypr`: the Hyprland Lua config and its helper scripts (`~/.config/hypr`). Generated and runtime
  files stay local and unversioned: Matugen's `colors.conf`, `lua/generated/colors.lua` and
  `hyprtoolkit.conf`, and the workspace-layout state `workspace-layouts.tsv`.
- `desktop-session`: personal systemd user units that join unified-quickshell's
  `unified-session.target`. These are the Herdr environment refresh, clipboard bridge restart,
  delayed media stack, tray layout, and the T3 Code and Grok Bot clients, which start after the
  tray layout so their windows never land in the hidden tray.

Session startup itself belongs to unified-quickshell. See its `docs/SESSION_AUTOSTART.md` and
`scripts/install-session`. `hypr/.config/hypr/lua/hypr/modules/startup.lua` loads that
module, or falls back to the old `session-bootstrap.sh` when it is not installed.

After stowing `desktop-session`, enable its units once:

```bash
systemctl --user enable unified-session-herdr.service unified-session-clipboard-bridge.service \
  unified-session-media.timer unified-session-tray.service \
  unified-session-t3code.service unified-session-grok-bot.service
```
