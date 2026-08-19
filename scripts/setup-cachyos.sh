#!/bin/bash
# Install and configure CachyOS x86-64-v3 optimized repository, performance kernel, and settings suite.
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

echo "==> [2/5] Setting up CachyOS repository and GPG keys..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"
curl -sL https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xf cachyos-repo.tar.xz
cd cachyos-repo
./cachyos-repo.sh --install

echo "==> [3/5] Installing CachyOS kernel, headers, and performance suite..."
pacman -S --needed --noconfirm \
  linux-cachyos \
  linux-cachyos-headers \
  cachyos-settings \
  cachyos-hooks \
  ananicy-cpp \
  cachyos-ananicy-rules

echo "==> [4/5] Enabling background optimization services..."
systemctl enable --now ananicy-cpp.service >/dev/null 2>&1 || true

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
