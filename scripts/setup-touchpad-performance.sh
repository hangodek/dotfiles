#!/bin/bash
# setup-touchpad-performance.sh — Boost Elantech PS/2 touchpad polling rate to 200Hz
# Halves motion-to-pixel latency from ~10ms (100Hz) to ~5ms (200Hz) for smooth tracking.

set -euo pipefail

CONF="/etc/modprobe.d/psmouse.conf"

echo "--> Configuring PS/2 touchpad report rate boost (200Hz)..."

if [[ $EUID -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    sudo tee "$CONF" > /dev/null << 'EOF'
# Boost Elantech PS/2 touchpad report rate from default 100Hz to 200Hz
options psmouse rate=200
EOF
  else
    echo "Error: root privileges required to write $CONF" >&2
    exit 1
  fi
else
  cat > "$CONF" << 'EOF'
# Boost Elantech PS/2 touchpad report rate from default 100Hz to 200Hz
options psmouse rate=200
EOF
fi

echo "--> Wrote $CONF successfully."
