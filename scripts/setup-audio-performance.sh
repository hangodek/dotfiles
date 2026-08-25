#!/bin/bash
# Setup Real-Time Audio Scheduling Permissions, Limits, and Power-Save Settings
# Usage: ./setup-audio-performance.sh

set -euo pipefail

echo "--> Configuring system audio real-time limits and power-save..."

# 1. Add current user to audio group if not already present
CURRENT_USER="${SUDO_USER:-$USER}"
if ! id -nG "$CURRENT_USER" | grep -qw "audio"; then
  echo "    Adding user $CURRENT_USER to audio group..."
  sudo usermod -aG audio "$CURRENT_USER" || true
fi

# 2. Configure real-time security limits for PipeWire, WirePlumber, and EasyEffects
LIMITS_FILE="/etc/security/limits.d/99-audio-realtime.conf"
if [[ ! -f "$LIMITS_FILE" ]] || ! grep -q "rtprio 95" "$LIMITS_FILE" 2>/dev/null; then
  echo "    Writing $LIMITS_FILE..."
  sudo tee "$LIMITS_FILE" > /dev/null << 'EOF'
# Real-time audio scheduling limits for low-latency DSP
@audio   - rtprio 95
@audio   - memlock unlimited
@audio   - nice -19
@wheel   - rtprio 95
@wheel   - memlock unlimited
@wheel   - nice -19
EOF
fi

# 3. Disable audio codec DAC power-save to prevent popping and wake-up clicks
MODPROBE_FILE="/etc/modprobe.d/audio_disable_powersave.conf"
if [[ ! -f "$MODPROBE_FILE" ]] || ! grep -q "power_save=0" "$MODPROBE_FILE" 2>/dev/null; then
  echo "    Writing $MODPROBE_FILE..."
  sudo tee "$MODPROBE_FILE" > /dev/null << 'EOF'
# Disable audio hardware power saving to prevent DAC sleep/wake popping
options snd_hda_intel power_save=0 power_save_controller=N
options snd_acp3x_pdm_dma power_save=0 2>/dev/null || true
EOF
fi

echo "--> Audio performance and real-time setup complete."
