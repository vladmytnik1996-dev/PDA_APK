#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

python3 tools/static_audit.py
python3 tools/smali_audit.py
./build.sh debug
python3 tools/binary_apk_audit.py build/outputs/app-debug.apk

if [[ -f signing/stalker-pda-release.jks && -f signing/release-password.txt ]]; then
  ./build.sh release
  python3 tools/binary_apk_audit.py build/outputs/app-release.apk
else
  echo "Release-проверка пропущена: материалы подписи не установлены в signing/."
fi

if python3 -c 'import playwright' >/dev/null 2>&1 && command -v chromium >/dev/null 2>&1; then
  python3 tools/web_dom_smoke.py
  python3 tools/camera_dom_smoke.py
  python3 tools/gps_calibration_qr_dom.py
else
  echo "DOM-тесты пропущены: Playwright/Chromium не найдены."
fi

unzip -t build/outputs/app-debug.apk >/dev/null
[[ ! -f build/outputs/app-release.apk ]] || unzip -t build/outputs/app-release.apk >/dev/null

echo "VERIFY_OK"
