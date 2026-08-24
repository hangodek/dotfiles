#!/bin/bash
# Installs and updates aggressive NVMe-tuned preload configuration.
# Usage: sudo bash ~/dotfiles/scripts/setup-preload.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRELOAD_SRC="$DOTFILES/config/preload/preload.conf"
PRELOAD_DEST="/etc/preload.conf"

echo "--> Checking aggressive NVMe preload configuration..."

if [[ ! -f "$PRELOAD_SRC" ]]; then
  echo "    Error: $PRELOAD_SRC not found." >&2
  exit 1
fi

if cmp -s "$PRELOAD_SRC" "$PRELOAD_DEST" 2>/dev/null; then
  echo "    Aggressive NVMe preload configuration is already active."
  exit 0
fi

if [[ $EUID -eq 0 ]] || [[ -w "$PRELOAD_DEST" ]]; then
  cp "$PRELOAD_SRC" "$PRELOAD_DEST"
  systemctl enable --now preload.service 2>/dev/null || true
  systemctl restart preload.service 2>/dev/null || true
  echo "    Preload daemon reloaded with aggressive NVMe settings."
else
  echo "    Notice: Root privileges required to update $PRELOAD_DEST (run with sudo to apply)."
fi
