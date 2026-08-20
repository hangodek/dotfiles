#!/bin/bash
# Restore personal Omarchy dotfiles after a fresh install or update.
# Usage: bash ~/dotfiles/bootstrap.sh [--cachyos]

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
INSTALL_CACHYOS=false

for arg in "$@"; do
  case "$arg" in
    --cachyos)
      INSTALL_CACHYOS=true
      ;;
    --help|-h)
      echo "Usage: bash ~/dotfiles/bootstrap.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --cachyos    Install CachyOS x86-64-v3 kernel and optimization suite"
      echo "  --help       Show this help message"
      exit 0
      ;;
  esac
done

echo "==> Restoring Omarchy personal dotfiles..."

echo "--> Linking Hyprland configs..."
mkdir -p "$HOME/.config/hypr"
for f in bindings.lua monitors.lua input.lua looknfeel.lua autostart.lua hyprland.lua; do
  src="$DOTFILES/config/hypr/$f"
  dst="$HOME/.config/hypr/$f"
  if [[ -f $src ]]; then
    if [[ -f $dst && ! -L $dst ]]; then
      cp "$dst" "$dst.bak.$(date +%s)"
    fi
    ln -sf "$src" "$dst"
    echo "    linked hypr/$f"
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

if [[ -d "$DOTFILES/config/tactile" ]]; then
  mkdir -p "$HOME/.config/tactile"
  ln -sf "$DOTFILES/config/tactile/config.json" "$HOME/.config/tactile/config.json"
  ln -sf "$DOTFILES/config/tactile/Tactile.qml" "$HOME/.config/tactile/Tactile.qml"
  echo "    linked tactile/config.json & Tactile.qml"
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

echo "--> Installing personal scripts..."
mkdir -p "$HOME/.local/bin"
for s in "$DOTFILES/local/bin/"*; do
  if [[ -f $s ]]; then
    base=$(basename "$s")
    ln -sf "$s" "$HOME/.local/bin/$base"
    chmod +x "$s"
    echo "    linked ~/.local/bin/$base"
  fi
done

echo "--> Validating Hyprland config..."
if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
  if hyprctl configerrors 2>&1 | grep -q "ok"; then
    echo "    Hyprland config validated successfully."
  fi
fi

echo "--> Ensuring core system real-time daemons (rtkit)..."
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm rtkit lsp-plugins-lv2 calf zam-plugins-lv2 >/dev/null 2>&1 || true
  sudo systemctl enable --now rtkit-daemon.service >/dev/null 2>&1 || true
fi

echo "--> Configuring default web browser (Microsoft Edge)..."
if command -v microsoft-edge-stable >/dev/null 2>&1; then
  env -u BROWSER xdg-settings set default-web-browser microsoft-edge.desktop >/dev/null 2>&1 || true
  xdg-mime default microsoft-edge.desktop x-scheme-handler/http >/dev/null 2>&1 || true
  xdg-mime default microsoft-edge.desktop x-scheme-handler/https >/dev/null 2>&1 || true
fi

echo "--> Ensuring TCP BBRv3 network congestion control..."
if [[ -f /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr.ko.zst ]]; then
  echo "tcp_bbr" | sudo tee /etc/modules-load.d/bbr.conf >/dev/null 2>&1 || true
  sudo modprobe tcp_bbr 2>/dev/null || true
  sudo tee /etc/sysctl.d/99-bbr.conf >/dev/null 2>&1 << 'EOF'
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
EOF
  sudo sysctl -p /etc/sysctl.d/99-bbr.conf >/dev/null 2>&1 || true
fi

echo "--> Applying smooth Spotlight zoom & fade animation to Omarchy Menu..."
if [[ -f "$DOTFILES/scripts/patch-smooth-menu.sh" ]]; then
  sudo bash "$DOTFILES/scripts/patch-smooth-menu.sh" >/dev/null 2>&1 || true
fi

if [[ "$INSTALL_CACHYOS" == "true" ]]; then
  echo ""
  echo "==> Triggering CachyOS Kernel & Performance Suite installation..."
  sudo bash "$DOTFILES/scripts/setup-cachyos.sh"
fi

echo "==> All personal configs and scripts successfully restored!"
