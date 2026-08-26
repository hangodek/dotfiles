#!/bin/bash
# Han's Omarchy & Hyprland Bulletproof Dotfiles Restorer
# Usage: ./bootstrap.sh [--cachyos]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHYOS_MODE=0

for arg in "$@"; do
  case "$arg" in
    --cachyos) CACHYOS_MODE=1 ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--cachyos]" >&2
      exit 1
      ;;
  esac
done

# Resolve real user and real home directory reliably
TARGET_USER="${SUDO_USER:-$(id -un)}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_UID="$(id -u "$TARGET_USER")"

echo "===================================================="
echo "Bootstrapping Han's Dotfiles for Omarchy"
echo "Target User: $TARGET_USER ($TARGET_HOME)"
echo "===================================================="

# 1. User-space configuration symlinks
echo "--> Linking Hyprland configs..."
mkdir -p "$TARGET_HOME/.config/hypr"
for f in "$DOTFILES/config/hypr/"*; do
  if [[ -f $f ]]; then
    base=$(basename "$f")
    ln -sf "$f" "$TARGET_HOME/.config/hypr/$base"
    echo "    linked hypr/$base"
  fi
done

echo "--> Linking Omarchy shell and extensions..."
mkdir -p "$TARGET_HOME/.config/omarchy/extensions"
if [[ -f "$DOTFILES/config/omarchy/shell.json" ]]; then
  ln -sf "$DOTFILES/config/omarchy/shell.json" "$TARGET_HOME/.config/omarchy/shell.json"
  echo "    linked omarchy/shell.json"
fi

if [[ -f "$DOTFILES/config/omarchy/extensions/omarchy-menu.jsonc" ]]; then
  ln -sf "$DOTFILES/config/omarchy/extensions/omarchy-menu.jsonc" "$TARGET_HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
  echo "    linked omarchy/extensions/omarchy-menu.jsonc"
fi

echo "--> Linking extra configs..."
if [[ -f "$DOTFILES/config/starship.toml" ]]; then
  ln -sf "$DOTFILES/config/starship.toml" "$TARGET_HOME/.config/starship.toml"
  echo "    linked starship.toml"
fi

if [[ -f "$DOTFILES/config/foot/foot.ini" ]]; then
  mkdir -p "$TARGET_HOME/.config/foot"
  ln -sf "$DOTFILES/config/foot/foot.ini" "$TARGET_HOME/.config/foot/foot.ini"
  echo "    linked foot/foot.ini"
fi

if [[ -f "$DOTFILES/config/git/config" ]]; then
  mkdir -p "$TARGET_HOME/.config/git"
  ln -sf "$DOTFILES/config/git/config" "$TARGET_HOME/.config/git/config"
  echo "    linked git/config"
fi

if [[ -f "$DOTFILES/config/bash/aliases.sh" ]]; then
  ln -sf "$DOTFILES/config/bash/aliases.sh" "$TARGET_HOME/.bash_aliases"
  echo "    linked ~/.bash_aliases"
  if ! grep -q ".bash_aliases" "$TARGET_HOME/.bashrc" 2>/dev/null; then
    echo "[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases" >> "$TARGET_HOME/.bashrc"
  fi
fi

if [[ -d "$DOTFILES/config/environment.d" ]]; then
  mkdir -p "$TARGET_HOME/.config/environment.d"
  for env_file in "$DOTFILES/config/environment.d/"*.conf; do
    if [[ -f "$env_file" ]]; then
      ln -sf "$env_file" "$TARGET_HOME/.config/environment.d/$(basename "$env_file")"
      echo "    linked $(basename "$env_file")"
    fi
  done
fi

echo "--> Linking PipeWire and WirePlumber low-latency configs..."
if [[ -d "$DOTFILES/config/pipewire" ]]; then
  mkdir -p "$TARGET_HOME/.config/pipewire/pipewire.conf.d"
  for pw_file in "$DOTFILES/config/pipewire/pipewire.conf.d/"*.conf; do
    if [[ -f "$pw_file" ]]; then
      ln -sf "$pw_file" "$TARGET_HOME/.config/pipewire/pipewire.conf.d/$(basename "$pw_file")"
      echo "    linked pipewire/$(basename "$pw_file")"
    fi
  done
fi

if [[ -d "$DOTFILES/config/wireplumber" ]]; then
  mkdir -p "$TARGET_HOME/.config/wireplumber/wireplumber.conf.d"
  for wp_file in "$DOTFILES/config/wireplumber/wireplumber.conf.d/"*.conf; do
    if [[ -f "$wp_file" ]]; then
      ln -sf "$wp_file" "$TARGET_HOME/.config/wireplumber/wireplumber.conf.d/$(basename "$wp_file")"
      echo "    linked wireplumber/$(basename "$wp_file")"
    fi
  done
fi

echo "--> Compiling high-performance native helpers..."
for src_c in "$DOTFILES/local/bin/"*.c; do
  if [[ -f "$src_c" ]]; then
    bin_name="${src_c%.c}"
    gcc -O3 "$src_c" -o "$bin_name"
    echo "    compiled $(basename "$bin_name") native helper"
  fi
done

echo "--> Installing personal scripts and binaries..."
mkdir -p "$TARGET_HOME/.local/bin"
for s in "$DOTFILES/local/bin/"*; do
  if [[ -f $s && ! "$s" =~ \.c$ ]]; then
    base=$(basename "$s")
    ln -sf "$s" "$TARGET_HOME/.local/bin/$base"
    chmod +x "$s"
    echo "    linked ~/.local/bin/$base"
  fi
done

# Fix ownership if running as sudo
if [[ $EUID -eq 0 && "$TARGET_USER" != "root" ]]; then
  chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/hypr/"* 2>/dev/null || true
  chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/omarchy/"* 2>/dev/null || true
  chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local/bin/"* 2>/dev/null || true
fi

# 2. System Patches & Automations (Spotlight, 1px slider, Preload, Audio, Pacman hook)
echo ""
echo "--> Restoring system-level patches and optimizations..."
if [[ -f "$DOTFILES/scripts/restore-system-patches.sh" ]]; then
  if [[ $EUID -eq 0 ]]; then
    bash "$DOTFILES/scripts/restore-system-patches.sh"
  elif command -v sudo >/dev/null 2>&1; then
    sudo bash "$DOTFILES/scripts/restore-system-patches.sh"
  else
    echo "Notice: Root privileges required for system patches. Run with sudo to apply."
  fi
fi

# 3. Reload session
echo ""
echo "--> Reloading session components..."
if [[ -n "${WAYLAND_DISPLAY:-}" || -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
    echo "    Hyprland config reloaded."
  fi
  if command -v omarchy-restart-shell >/dev/null 2>&1; then
    omarchy-restart-shell >/dev/null 2>&1 || true
    echo "    Omarchy top bar reloaded."
  fi
fi

# Optional CachyOS Performance Kernel & Sysctl setup
if (( CACHYOS_MODE )); then
  echo ""
  echo "--> Running CachyOS Performance & Kernel Installer..."
  if [[ -f "$DOTFILES/scripts/setup-cachyos.sh" ]]; then
    bash "$DOTFILES/scripts/setup-cachyos.sh"
  fi
fi

echo "===================================================="
echo "Dotfiles restore complete and verified."
echo "===================================================="
