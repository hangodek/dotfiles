#!/bin/bash
# Download and configure GParted Live to boot directly from RAM via Limine Bootloader
# Usage: sudo bash ~/dotfiles/scripts/setup-gparted-iso.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root (use sudo)." >&2
  exit 1
fi

GPARTED_DIR="/boot/gparted"
ISO_URL="https://downloads.sourceforge.net/gparted/gparted-live-1.6.0-10-amd64.iso"
ISO_PATH="$GPARTED_DIR/gparted.iso"
LIMINE_CONF="/boot/limine.conf"

echo "==> [1/4] Preparing /boot/gparted directory..."
mkdir -p "$GPARTED_DIR"

echo "==> [2/4] Downloading GParted Live ISO (~450MB)..."
curl -L --progress-bar -o "$ISO_PATH" "$ISO_URL"

echo "==> [3/4] Extracting Linux kernel and initrd from ISO..."
bsdtar -xf "$ISO_PATH" -C "$GPARTED_DIR" live/vmlinuz live/initrd.img
mv -f "$GPARTED_DIR/live/vmlinuz" "$GPARTED_DIR/vmlinuz"
mv -f "$GPARTED_DIR/live/initrd.img" "$GPARTED_DIR/initrd.img"
rm -rf "$GPARTED_DIR/live"

echo "==> [4/4] Adding GParted Live entry to /boot/limine.conf..."
# Remove any existing GParted entry first
if grep -q "^/GParted Live" "$LIMINE_CONF"; then
  sed -i '/^\/GParted Live/,+5d' "$LIMINE_CONF"
fi

cat >> "$LIMINE_CONF" << 'EOF'

/GParted Live (RAM)
  protocol: linux
  kernel_path: boot():/gparted/vmlinuz
  initrd_path: boot():/gparted/initrd.img
  cmdline: boot=live config components union=overlay username=user noswap noeject toram=filesystem.squashfs findiso=/gparted/gparted.iso
EOF

echo ""
echo "================================================================="
echo "  GParted Live successfully installed into Limine Bootloader!"
echo "  Files created in /boot/gparted/:"
ls -lh "$GPARTED_DIR"
echo ""
echo "  To resize your partition:"
echo "  1. Reboot your laptop: systemctl reboot"
echo "  2. At the Limine boot screen, select 'GParted Live (RAM)'"
echo "  3. When GParted opens:"
echo "     - Right-click OMARCHY_ROOT -> Resize/Move"
echo "     - Drag the LEFT side completely to the left (to consume the 51GB free space)"
echo "     - Click 'Apply' (Checkmark icon)"
echo "  4. Reboot back into Omarchy!"
echo "================================================================="
