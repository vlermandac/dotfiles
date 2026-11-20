#!/usr/bin/python3
"""Send small horizontal-scroll steps to the Wayland compositor.

The daemon keeps a single uinput device open so a knob detent does not pay the
udev device-discovery delay.  Hyprland calls the client mode for each detent;
the daemon then emits one native REL_HWHEEL event, which Ardour handles like a
horizontal mouse-wheel step.
"""

from __future__ import annotations

import argparse
import errno
import os
from pathlib import Path
import signal
import socket
import sys

from evdev import UInput, ecodes as e


SOCKET_PATH = (
    Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
    / "ardour-knob-scroll.sock"
)
DEVICE_NAME = "Ardour knob scroll"


def _daemon_is_alive(path: Path) -> bool:
    """Return whether a listening daemon answers a short health check."""

    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as probe:
            probe.settimeout(0.25)
            probe.connect(str(path))
            probe.sendall(b"ping")
            return probe.recv(4) == b"pong"
    except OSError:
        return False


def _bind_server(path: Path) -> socket.socket:
    """Bind the IPC socket, recovering only an unresponsive stale socket."""

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        server.bind(str(path))
    except OSError as exc:
        if exc.errno != errno.EADDRINUSE:
            server.close()
            raise

        if _daemon_is_alive(path):
            server.close()
            raise SystemExit(0)

        # The path is a socket that no process is serving anymore.  Do not
        # remove arbitrary files if the path was replaced unexpectedly.
        try:
            if not path.is_socket():
                server.close()
                raise RuntimeError(f"refusing to remove non-socket {path}")
            path.unlink()
        except FileNotFoundError:
            pass

        server.bind(str(path))

    os.chmod(path, 0o600)
    server.listen(16)
    server.settimeout(1.0)
    return server


def run_daemon() -> int:
    """Serve left/right commands and emit native horizontal wheel events."""

    SOCKET_PATH.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    server = _bind_server(SOCKET_PATH)
    stopping = False

    def stop(_signum: int, _frame: object) -> None:
        nonlocal stopping
        stopping = True

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)

    try:
        # REL_HWHEEL is intentionally used instead of a key event.  Ardour's
        # normal horizontal-scroll path advances by one eighth of a visible
        # page, substantially smaller than its keyboard scroll action.
        ui = UInput(
            {e.EV_REL: [e.REL_HWHEEL]},
            name=DEVICE_NAME,
            phys="ardour-knob-scroll",
        )
    except Exception:
        server.close()
        try:
            SOCKET_PATH.unlink()
        except FileNotFoundError:
            pass
        raise

    try:
        while not stopping:
            try:
                connection, _address = server.accept()
            except socket.timeout:
                continue

            with connection:
                command = connection.recv(16).strip().lower()
                if command == b"ping":
                    connection.sendall(b"pong")
                    continue
                if command == b"left":
                    delta = -1
                elif command == b"right":
                    delta = 1
                else:
                    continue

                ui.write(e.EV_REL, e.REL_HWHEEL, delta)
                ui.syn()
    finally:
        ui.close()
        server.close()
        try:
            SOCKET_PATH.unlink()
        except FileNotFoundError:
            pass

    return 0


def send_step(direction: str) -> int:
    """Ask the resident daemon to emit one horizontal-scroll step."""

    if direction not in {"left", "right"}:
        raise ValueError(f"unknown direction: {direction}")

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(0.5)
        client.connect(str(SOCKET_PATH))
        client.sendall(direction.encode("ascii"))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--daemon", action="store_true", help="run the resident input daemon")
    parser.add_argument("direction", nargs="?", choices=("left", "right"))
    args = parser.parse_args()

    if args.daemon:
        if args.direction is not None:
            parser.error("--daemon cannot be combined with a direction")
        return run_daemon()
    if args.direction is None:
        parser.error("a direction is required unless --daemon is used")
    return send_step(args.direction)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (BrokenPipeError, ConnectionError, FileNotFoundError) as exc:
        print(f"ardour-knob-scroll: {exc}", file=sys.stderr)
        raise SystemExit(1)
