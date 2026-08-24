#!/bin/bash
# Configure ALSA DAC headroom, PipeWire soft-peak limiter, and EasyEffects routing matching Fedora Workstation standards.
# Usage: ./setup-audio-easyeffects.sh

set -euo pipefail

echo "--> Setting ALSA hardware DAC levels to 100% (0.00 dB headroom)..."
for card in 0 1; do
  amixer -c "$card" sset Master 100% unmute 2>/dev/null || true
  amixer -c "$card" sset Speaker 100% unmute 2>/dev/null || true
  amixer -c "$card" sset PCM 100% unmute 2>/dev/null || true
done

echo "--> Linking PipeWire soft-peak limiter configuration..."
mkdir -p "$HOME/.config/pipewire/pipewire.conf.d" "$HOME/.config/pipewire/pipewire-pulse.conf.d"
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$DOTFILES/config/pipewire/pipewire.conf.d/99-resample-peaks.conf" ]]; then
  ln -sf "$DOTFILES/config/pipewire/pipewire.conf.d/99-resample-peaks.conf" "$HOME/.config/pipewire/pipewire.conf.d/99-resample-peaks.conf"
fi

if [[ -f "$DOTFILES/config/pipewire/pipewire-pulse.conf.d/99-resample-peaks.conf" ]]; then
  ln -sf "$DOTFILES/config/pipewire/pipewire-pulse.conf.d/99-resample-peaks.conf" "$HOME/.config/pipewire/pipewire-pulse.conf.d/99-resample-peaks.conf"
fi

echo "--> Locking EasyEffects input sink to 100% unity gain and setting default routing..."
if pactl list sinks short 2>/dev/null | grep -q "easyeffects_sink"; then
  pactl set-sink-volume easyeffects_sink 100% 2>/dev/null || true
  pactl set-default-sink easyeffects_sink 2>/dev/null || true
fi
