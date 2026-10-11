#!/bin/bash
# Automatically configure Omarchy dev channel and install required dev packages

set -euo pipefail

echo "--> Checking Omarchy package channel and dev packages..."

current_channel=""
if command -v omarchy >/dev/null 2>&1; then
  current_channel=$(omarchy channel current 2>/dev/null || true)
fi

# 1. Ensure dev channel is active
if [[ "$current_channel" != "dev" ]]; then
  echo "    Switching Omarchy channel to dev..."
  omarchy channel set dev
else
  echo "    Omarchy channel is already set to dev."
fi

# 2. Ensure omarchy-dev and omarchy-settings-dev packages are installed
need_install=0
for pkg in omarchy-dev omarchy-settings-dev; do
  if ! pacman -Q "$pkg" >/dev/null 2>&1; then
    need_install=1
    break
  fi
done

if (( need_install )); then
  echo "    Installing omarchy-dev and omarchy-settings-dev (replacing release packages)..."
  sudo pacman -S --noconfirm --needed omarchy-dev omarchy-settings-dev
else
  echo "    Dev packages (omarchy-dev, omarchy-settings-dev) already installed."
fi

# 3. Run pending migrations if any
echo "    Running pending Omarchy migrations..."
omarchy migrate || true
echo "    Omarchy dev channel setup verified."
