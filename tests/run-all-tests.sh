#!/bin/bash
# Master test and benchmark runner for Han's Dotfiles
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$DIR/benchmark_suite.py"

python3 "$DIR/benchmark_suite.py"
