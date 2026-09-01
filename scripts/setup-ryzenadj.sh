#!/bin/bash
# Install and configure RyzenAdj for AMD Ryzen Mobile (Picasso / Zen+)
# Enables --max-performance with 25W-30W power limit on battery for full Turbo Boost.
# Usage: sudo bash ~/dotfiles/scripts/setup-ryzenadj.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root (use sudo)." >&2
  exit 1
fi

echo "==> [1/4] Checking / Installing RyzenAdj binary..."
if [[ ! -x "/usr/local/bin/ryzenadj" ]]; then
  echo "    Installing build dependencies..."
  pacman -S --needed --noconfirm cmake pciutils gcc make git

  TMP_BUILD=$(mktemp -d)
  trap 'rm -rf "$TMP_BUILD"' EXIT

  echo "    Building RyzenAdj from source..."
  git clone --depth 1 https://github.com/FlyGoat/RyzenAdj.git "$TMP_BUILD"
  mkdir -p "$TMP_BUILD/build"
  cd "$TMP_BUILD/build"

  cmake -DCMAKE_BUILD_TYPE=Release ..
  make -j"$(nproc)"

  install -Dm755 ryzenadj /usr/local/bin/ryzenadj
  install -Dm644 libryzenadj.so /usr/local/lib/libryzenadj.so
else
  echo "    RyzenAdj binary already installed at /usr/local/bin/ryzenadj."
fi

echo "==> [2/4] Creating systemd service for boot persistence..."
cat > /etc/systemd/system/ryzenadj-power.service << 'SERVICE_EOF'
[Unit]
Description=AMD Ryzen Mobile APU Power Unlocker (25W-30W Max Performance)
After=multi-user.target sleep.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ryzenadj --max-performance --stapm-limit=25000 --fast-limit=30000 --slow-limit=25000 --tctl-temp=85
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target sleep.target
SERVICE_EOF

echo "==> [3/4] Creating system-sleep hook for resume persistence..."
mkdir -p /usr/lib/systemd/system-sleep
cat > /usr/lib/systemd/system-sleep/ryzenadj-sleep.sh << 'SLEEP_EOF'
#!/bin/bash
case "$1/$2" in
  post/*)
    /usr/local/bin/ryzenadj --max-performance --stapm-limit=25000 --fast-limit=30000 --slow-limit=25000 --tctl-temp=85 >/dev/null 2>&1 || true
    ;;
esac
SLEEP_EOF
chmod +x /usr/lib/systemd/system-sleep/ryzenadj-sleep.sh

systemctl daemon-reload
systemctl enable --now ryzenadj-power.service

echo "==> [4/4] Applying 25W/30W Turbo Boost with --max-performance immediately..."
/usr/local/bin/ryzenadj --max-performance --stapm-limit=25000 --fast-limit=30000 --slow-limit=25000 --tctl-temp=85 || true

echo ""
echo "================================================================="
echo "  RyzenAdj Max Performance successfully installed & active!"
echo "  - Mode: --max-performance (AC-grade aggressive boost on battery)"
echo "  - Sustained Power (STAPM): 25W (up from 12W limit on battery)"
echo "  - Fast Turbo Burst Limit: 30W"
echo "  - Safe Thermal Throttle: 85°C"
echo "================================================================="
