#!/usr/bin/env bash

set -euo pipefail

# Let the desktop settle before waking Docker and the compose stack.
sleep 20

if systemctl --user is-active --quiet media-stack.service; then
  exit 0
fi

systemctl --user start media-stack.service
