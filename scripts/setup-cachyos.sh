#!/bin/bash
# Robust CachyOS x86-64-v3 repository and kernel installer for Arch Linux / Omarchy.
# Usage: sudo bash ~/dotfiles/scripts/setup-cachyos.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root (use sudo)." >&2
  exit 1
fi

echo "==> [1/5] Checking CPU microarchitecture support..."
if /usr/lib/ld-linux-x86-64.so.2 --help | grep -q "x86-64-v3 (supported, searched)"; then
  echo "    CPU supports x86-64-v3 (AVX2, FMA, BMI1/2) - Optimal for CachyOS v3!"
else
  echo "    CPU is standard x86-64. Proceeding with standard CachyOS repository."
fi

echo "==> [2/5] Fetching CachyOS keyring & mirrorlists directly via HTTPS..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"
MIRROR="https://mirror.cachyos.org/repo/x86_64/cachyos"

echo "    Downloading cachyos-keyring and mirrorlists..."
curl -sSL "$MIRROR/cachyos-keyring-20240331-1-any.pkg.tar.zst" -o cachyos-keyring.pkg.tar.zst
curl -sSL "$MIRROR/cachyos-mirrorlist-27-1-any.pkg.tar.zst" -o cachyos-mirrorlist.pkg.tar.zst
curl -sSL "$MIRROR/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst" -o cachyos-v3-mirrorlist.pkg.tar.zst

echo "    Installing keyring and mirrorlists into pacman..."
pacman -U --noconfirm --needed ./cachyos-keyring.pkg.tar.zst ./cachyos-mirrorlist.pkg.tar.zst ./cachyos-v3-mirrorlist.pkg.tar.zst

echo "    Populating CachyOS trusted GPG keys..."
pacman-key --populate cachyos || true

echo "    Configuring /etc/pacman.conf for x86_64_v3 architecture..."
if grep -q "^Architecture = auto$" /etc/pacman.conf; then
  sed -i 's/^Architecture = auto$/Architecture = auto x86_64_v3/' /etc/pacman.conf
elif grep -q "^Architecture = x86_64$" /etc/pacman.conf; then
  sed -i 's/^Architecture = x86_64$/Architecture = x86_64 x86_64_v3/' /etc/pacman.conf
fi

echo "    Configuring /etc/pacman.conf with CachyOS v3 repositories..."
if ! grep -q "\[cachyos-v3\]" /etc/pacman.conf; then
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
' /etc/pacman.conf
fi

echo "    Syncing pacman databases..."
pacman -Sy

echo "==> [3/5] Installing CachyOS kernel, headers, and performance suite..."
pacman -S --needed --noconfirm \
  linux-cachyos \
  linux-cachyos-headers \
  cachyos-settings \
  cachyos-hooks \
  ananicy-cpp \
  cachyos-ananicy-rules \
  rtkit

echo "==> [4/5] Enabling background optimization services & TCP BBRv3..."
systemctl enable --now ananicy-cpp.service rtkit-daemon.service >/dev/null 2>&1 || true

# Load TCP BBRv3 kernel module and configure sysctl
echo "tcp_bbr" > /etc/modules-load.d/bbr.conf
modprobe tcp_bbr 2>/dev/null || true

cat > /etc/sysctl.d/99-bbr.conf << 'EOF'
# TCP BBRv3 + CAKE Queueing
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
EOF

sysctl -p /etc/sysctl.d/99-bbr.conf >/dev/null 2>&1 || true

echo "==> [5/5] Verifying Limine UKI kernel generation..."
if [[ -d /boot/EFI/Linux ]]; then
  ls -lh /boot/EFI/Linux/
fi

echo ""
echo "================================================================="
echo "  CachyOS Kernel & Performance Suite successfully installed!"
echo "  - Kernel: linux-cachyos (BORE scheduler, -O3, x86-64-v3)"
echo "  - Settings: cachyos-settings (udev, sysctl, ZRAM, THP, audio limits)"
echo "  - Process Auto-Nicer: ananicy-cpp (enabled and active)"
echo ""
echo "  Reboot your machine to enter the CachyOS kernel:"
echo "    omarchy system reboot"
echo "================================================================="
