#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
command -v python >/dev/null 2>&1 || { echo "Сначала установите Python: pkg install python"; exit 1; }
python server.py --port 8080
