# PDF reader: Zathura, migrated 2026-10-17

The owner retired Sioyek after repeated failures, most recently a crash when
opening its `:` command line. Do not restore Sioyek, its color-rewriting hooks,
or its custom graphics-repair deployment as the active reader.

The replacement is Zathura 2026.07.18 from Flathub, installed **for this user** as
`org.pwmt.zathura`, using its pdf-poppler plugin. This installation required no
administrator authentication and separates reader dependencies from host
MuPDF/Qt upgrades. Updates are managed by Flatpak.

## Active entrypoints

- PDF MIME default: `org.pwmt.zathura-pdf-poppler.desktop`.
- `~/.local/bin/zathura`: transparent Flatpak CLI launcher.
- `~/.local/bin/pdf-open`: common opener used by Yazi and desktop tools.
- `~/.local/bin/yazi-open-pdf`: retained for existing Yazi sessions and file URLs.
- `~/.local/bin/sioyek-open-pdf`: compatibility name for existing cached callers;
  delegates to `pdf-open` and does not execute Sioyek.
- `~/.local/bin/sioyek-vimtex-light`: compatibility for old running VimTeX
  sessions; opens their PDF in Zathura. New VimTeX sessions use `zathura_simple`.

The Flatpak uses Wayland only, with its fallback display socket disabled.
Home and mounted-file access remains available for ordinary reading; `/tmp` and
GVfs access allow opening existing temporary/removable documents.

## Presentation and navigation

Settings live in
`~/.var/app/org.pwmt.zathura/config/zathura/zathurarc`. Pages retain their original
colors, recoloring is disabled, and Ctrl+R no longer toggles inversion. The
interface uses a static light palette. There is no Matugen PDF recoloring hook.

Use `h/j/k/l` or arrows to scroll, `gg`/`G` for first/last page, `/` to search,
`n`/`N` for matches, `:` for commands, `+`/`-` for zoom and `q` to close.

## VimTeX limitation

The current Flathub build does not link libsynctex. VimTeX therefore opens
Zathura with its Wayland-suitable `zathura_simple` method and explicitly disables
unsupported SyncTeX flags. PDF viewing and file auto-reload remain available;
forward/inverse source jumps are unavailable in this build. Do not replace
working viewing with an unsupported command or add display-server fallbacks.

## Preserved legacy data

Sioyek configuration, history and annotations have not been deleted. The
existing recent-document tool may still read its history without running it.
The root-owned Sioyek package remains installed because administrative access
was unavailable and the owner explicitly prohibited password requests. Its
desktop entry is hidden and active entrypoints now use Zathura. Uninstalling
that inactive package can be handled during a future authorized package cleanup.

The Matugen consumer registry marks Sioyek disabled, and the older standalone
theme refresh script no longer invokes its theme generator.

## Verification

A real PDF rendered with black text on white pages in a mapped native Wayland
window. Guarded keyboard input opened `:`, executed `set recolor false`, used
`j`, and quit through `:quit` without a crash. A fresh Yazi instance's Enter
action launched Zathura through the configured opener. The MIME default was
queried after updating it. User bookmarks/documents were not modified.

References: https://pwmt.org/projects/zathura/documentation/ and
https://flathub.org/apps/org.pwmt.zathura
