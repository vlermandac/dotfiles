#!/bin/sh

# Get the name of the currently focused monitor
MONITOR_NAME=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

# Launch kitty with an override only for HDMI-A-1
if [ "$MONITOR_NAME" = "HDMI-A-1" ]; then
  kitty --override "font_size=17"
else
  kitty
fi
