#!/bin/bash
# Han's Omarchy & Hyprland Dotfiles Restorer
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

echo "===================================================="
echo "Bootstrapping Han's Dotfiles for Omarchy"
echo "===================================================="

echo "--> Linking Hyprland configs..."
mkdir -p "$HOME/.config/hypr"
for f in "$DOTFILES/config/hypr/"*; do
  if [[ -f $f ]]; then
    base=$(basename "$f")
    ln -sf "$f" "$HOME/.config/hypr/$base"
    echo "    linked hypr/$base"
  fi
done

echo "--> Linking Omarchy shell and extensions..."
mkdir -p "$HOME/.config/omarchy/extensions"
if [[ -f "$DOTFILES/config/omarchy/shell.json" ]]; then
  ln -sf "$DOTFILES/config/omarchy/shell.json" "$HOME/.config/omarchy/shell.json"
  echo "    linked omarchy/shell.json"
fi

if [[ -f "$DOTFILES/config/omarchy/extensions/omarchy-menu.jsonc" ]]; then
  ln -sf "$DOTFILES/config/omarchy/extensions/omarchy-menu.jsonc" "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
  echo "    linked omarchy/extensions/omarchy-menu.jsonc"
fi

echo "--> Linking extra configs..."
if [[ -f "$DOTFILES/config/starship.toml" ]]; then
  ln -sf "$DOTFILES/config/starship.toml" "$HOME/.config/starship.toml"
  echo "    linked starship.toml"
fi

if [[ -f "$DOTFILES/config/foot/foot.ini" ]]; then
  mkdir -p "$HOME/.config/foot"
  ln -sf "$DOTFILES/config/foot/foot.ini" "$HOME/.config/foot/foot.ini"
  echo "    linked foot/foot.ini"
fi

if [[ -f "$DOTFILES/config/git/config" ]]; then
  mkdir -p "$HOME/.config/git"
  ln -sf "$DOTFILES/config/git/config" "$HOME/.config/git/config"
  echo "    linked git/config"
fi

if [[ -f "$DOTFILES/config/bash/aliases.sh" ]]; then
  ln -sf "$DOTFILES/config/bash/aliases.sh" "$HOME/.bash_aliases"
  echo "    linked ~/.bash_aliases"
  if ! grep -q ".bash_aliases" "$HOME/.bashrc" 2>/dev/null; then
    echo "[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases" >> "$HOME/.bashrc"
  fi
fi

if [[ -d "$DOTFILES/config/environment.d" ]]; then
  mkdir -p "$HOME/.config/environment.d"
  for env_file in "$DOTFILES/config/environment.d/"*.conf; do
    if [[ -f "$env_file" ]]; then
      ln -sf "$env_file" "$HOME/.config/environment.d/$(basename "$env_file")"
      echo "    linked $(basename "$env_file")"
    fi
  done
fi

echo "--> Linking PipeWire and WirePlumber low-latency configs..."
if [[ -d "$DOTFILES/config/pipewire" ]]; then
  mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
  for pw_file in "$DOTFILES/config/pipewire/pipewire.conf.d/"*.conf; do
    if [[ -f "$pw_file" ]]; then
      ln -sf "$pw_file" "$HOME/.config/pipewire/pipewire.conf.d/$(basename "$pw_file")"
      echo "    linked pipewire/$(basename "$pw_file")"
    fi
  done
fi

if [[ -d "$DOTFILES/config/wireplumber" ]]; then
  mkdir -p "$HOME/.config/wireplumber/wireplumber.conf.d"
  for wp_file in "$DOTFILES/config/wireplumber/wireplumber.conf.d/"*.conf; do
    if [[ -f "$wp_file" ]]; then
      ln -sf "$wp_file" "$HOME/.config/wireplumber/wireplumber.conf.d/$(basename "$wp_file")"
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
mkdir -p "$HOME/.local/bin"
for s in "$DOTFILES/local/bin/"*; do
  if [[ -f $s && ! "$s" =~ \.c$ ]]; then
    base=$(basename "$s")
    ln -sf "$s" "$HOME/.local/bin/$base"
    chmod +x "$s"
    echo "    linked ~/.local/bin/$base"
  fi
done

echo "--> Applying smooth App Menu Spotlight patch..."
if [[ -f "$DOTFILES/scripts/patch-smooth-menu.sh" ]]; then
  bash "$DOTFILES/scripts/patch-smooth-menu.sh" || true
fi

echo "--> Applying 1px font size slider patch for Navbar..."
if [[ -f "$DOTFILES/scripts/patch-navbar-font-slider.sh" ]]; then
  bash "$DOTFILES/scripts/patch-navbar-font-slider.sh" || true
fi

echo "--> Configuring aggressive NVMe preload daemon..."
if [[ -f "$DOTFILES/scripts/setup-preload.sh" ]]; then
  bash "$DOTFILES/scripts/setup-preload.sh" || true
fi

echo "--> Patching terminal launcher with scratchpad routing..."
if [[ -f "$DOTFILES/scripts/patch-terminal-scratchpad-routing.sh" ]]; then
  bash "$DOTFILES/scripts/patch-terminal-scratchpad-routing.sh" || true
fi

echo "--> Configuring real-time audio performance and limits..."
if [[ -f "$DOTFILES/scripts/setup-audio-performance.sh" ]]; then
  bash "$DOTFILES/scripts/setup-audio-performance.sh" || true
fi

echo "--> Validating Hyprland config..."
if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
  echo "    Hyprland config reloaded."
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
echo "Dotfiles restore complete."
echo "===================================================="
