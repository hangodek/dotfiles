#!/bin/bash
# Master system patch restorer for Han's Omarchy dotfiles
# Automatically restores all system-level customizations in /usr/share/omarchy, /usr/bin, and /etc.
# Called by bootstrap.sh and /etc/pacman.d/hooks/99-omarchy-dotfiles-restore.hook

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

echo "===================================================="
echo "Restoring Han's Omarchy System Patches & Optimizations"
echo "===================================================="

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    exec sudo "$0" "$@"
  else
    echo "Error: Root permissions required." >&2
    exit 1
  fi
fi

# 1. Spotlight App Menu Animation
if [[ -f "$DOTFILES/scripts/patch-smooth-menu.sh" ]]; then
  bash "$DOTFILES/scripts/patch-smooth-menu.sh" || true
fi

# 2. Navbar 1px Font Size Slider
if [[ -f "$DOTFILES/scripts/patch-navbar-font-slider.sh" ]]; then
  bash "$DOTFILES/scripts/patch-navbar-font-slider.sh" || true
fi

# 3. Top Bar Full-Width Indicator Component
if [[ -f "$DOTFILES/scripts/patch-fullwidth-indicator.sh" ]]; then
  bash "$DOTFILES/scripts/patch-fullwidth-indicator.sh" || true
fi

# 4. NVMe Aggressive Preload Daemon
if [[ -f "$DOTFILES/scripts/setup-preload.sh" ]]; then
  bash "$DOTFILES/scripts/setup-preload.sh" || true
fi

# 5. Real-Time Audio Performance & Limits
if [[ -f "$DOTFILES/scripts/setup-audio-performance.sh" ]]; then
  bash "$DOTFILES/scripts/setup-audio-performance.sh" || true
fi

# 6. Preserve CachyOS Pre-Compiled Binary Repositories in /etc/pacman.conf
PACMAN_CONF="/etc/pacman.conf"
if [[ -f "$PACMAN_CONF" && -f "/etc/pacman.d/cachyos-v3-mirrorlist" ]]; then
  if ! grep -q "\[cachyos-v3\]" "$PACMAN_CONF"; then
    echo "--> Restoring CachyOS binary repositories into $PACMAN_CONF..."
    # Ensure x86_64_v3 architecture is enabled
    sed -i 's/^Architecture = auto$/Architecture = auto x86_64_v3/' "$PACMAN_CONF" 2>/dev/null || true
    sed -i 's/^Architecture = x86_64$/Architecture = x86_64 x86_64_v3/' "$PACMAN_CONF" 2>/dev/null || true
    # Insert CachyOS repositories before [core]
    sed -i '/^\[core\]/i \
[cachyos-v3]\
Include = /etc/pacman.d/cachyos-v3-mirrorlist\
\
[cachyos-core-v3]\
Include = /etc/pacman.d/cachyos-v3-mirrorlist\
\
[cachyos-extra-v3]\
Include = /etc/pacman.d/cachyos-v3-mirrorlist\
\
[cachyos]\
Include = /etc/pacman.d/cachyos-mirrorlist\
' "$PACMAN_CONF"
  fi
fi

# 7. Ensure Essential Dialog Utilities (Zenity for Electron/Wine/script file dialogs)
if command -v pacman >/dev/null 2>&1; then
  echo "--> Ensuring zenity dialog engine is installed..."
  pacman -S --needed --noconfirm zenity >/dev/null 2>&1 || true
fi

# 8. Install / Update Pacman Post-Transaction Hook
HOOKS_DIR="/etc/pacman.d/hooks"
HOOK_FILE="$HOOKS_DIR/99-omarchy-dotfiles-restore.hook"
mkdir -p "$HOOKS_DIR"

tee "$HOOK_FILE" > /dev/null << 'EOF'
[Trigger]
Operation = Upgrade
Operation = Install
Type = Package
Target = omarchy*
Target = hyprland*

[Action]
Description = Restoring Han's Omarchy dotfile patches and custom optimizations...
When = PostTransaction
Exec = /home/han/dotfiles/scripts/restore-system-patches.sh
EOF

echo "--> Pacman automatic restore hook installed: $HOOK_FILE"

# 8. Reload Hyprland and restart Omarchy shell if a user session is active
REAL_USER="${SUDO_USER:-han}"
REAL_UID="$(id -u "$REAL_USER" 2>/dev/null || echo 1000)"

if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
  # Trigger shell restart and Hyprland reload under user session
  su - "$REAL_USER" -c '
    export XDG_RUNTIME_DIR="/run/user/'"$REAL_UID"'"
    if command -v omarchy-restart-shell >/dev/null 2>&1; then
      omarchy-restart-shell >/dev/null 2>&1 || true
    fi
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl reload >/dev/null 2>&1 || true
    fi
  ' || true
fi

echo "===================================================="
echo "System patches and optimizations restored."
echo "===================================================="
