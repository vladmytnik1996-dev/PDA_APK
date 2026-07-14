#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-all}"
case "$MODE" in
  all|debug|release) ;;
  *) echo "Использование: ./build.sh [all|debug|release]" >&2; exit 2 ;;
esac

APKTOOL="$ROOT/tools/lib/apktool-cli-3.0.2.jar"
APKSIG="$ROOT/tools/lib/apksig-2.3.0.jar"
ZIPALIGN="$ROOT/tools/zipalign4.py"
SOURCE="$ROOT/android/apktool-app"
BUILD="$ROOT/build"
OUT="$BUILD/outputs"
TMP="$BUILD/tmp"
RESULTS="$ROOT/test-results"
mkdir -p "$OUT" "$TMP" "$RESULTS"

command -v java >/dev/null || { echo "Требуется Java 17+" >&2; exit 1; }
command -v javac >/dev/null || { echo "Требуется javac (JDK 17+)" >&2; exit 1; }
command -v python3 >/dev/null || { echo "Требуется Python 3" >&2; exit 1; }
[[ -f "$APKTOOL" ]] || { echo "Не найден $APKTOOL" >&2; exit 1; }
[[ -f "$APKSIG" ]] || { echo "Не найден $APKSIG" >&2; exit 1; }
[[ -f "$ZIPALIGN" ]] || { echo "Не найден $ZIPALIGN" >&2; exit 1; }

if [[ ! -f "$ROOT/signing/stalker-pda-debug.jks" ]]; then
  mkdir -p "$ROOT/signing"
  keytool -genkeypair -keystore "$ROOT/signing/stalker-pda-debug.jks" -storetype JKS \
    -storepass android -keypass android -alias androiddebugkey -keyalg RSA -keysize 2048 \
    -sigalg SHA256withRSA -validity 10000 -dname "CN=Android Debug, O=Android, C=US"
fi

rm -rf "$TMP/signer-classes"
mkdir -p "$TMP/signer-classes"
javac -cp "$APKSIG" -d "$TMP/signer-classes" "$ROOT/tools/ApkSignerTool.java"
JAVA_EXPORT=(--add-exports java.base/sun.security.x509=ALL-UNNAMED --add-exports java.base/sun.security.pkcs=ALL-UNNAMED --add-exports java.base/sun.security.util=ALL-UNNAMED)
CP="$APKSIG:$TMP/signer-classes"

prepare_variant() {
  local variant="$1" dst="$TMP/$1"
  rm -rf "$dst"
  cp -a "$SOURCE" "$dst"
  rm -rf "$dst/build"
  if [[ "$variant" == "debug" ]]; then
    python3 - "$dst" <<'PY'
from pathlib import Path
import sys
root=Path(sys.argv[1])
manifest=root/'AndroidManifest.xml'
s=manifest.read_text('utf-8')
s=s.replace('package="by.smorhon.stalkerpda.v3"', 'package="by.smorhon.stalkerpda.v6.debug"', 1)
s=s.replace('android:versionName="1.0.5"', 'android:versionName="1.0.5-debug"', 1)
s=s.replace('android:name=".MainActivity"', 'android:name="by.smorhon.stalkerpda.MainActivity"', 1)
manifest.write_text(s,'utf-8')
strings=root/'res/values/strings.xml'
s=strings.read_text('utf-8').replace('КПК Зоны</string>', 'КПК Зоны (Debug)</string>', 1)
strings.write_text(s,'utf-8')
yml=root/'apktool.yml'
s=yml.read_text('utf-8').replace('versionName: 1.0.5', 'versionName: 1.0.5-debug', 1)
yml.write_text(s,'utf-8')
PY
  fi
}

build_debug() {
  prepare_variant debug
  java -jar "$APKTOOL" b -f "$TMP/debug" -o "$TMP/app-debug-unsigned.apk"
  python3 "$ZIPALIGN" "$TMP/app-debug-unsigned.apk" "$TMP/app-debug-aligned.apk"
  java "${JAVA_EXPORT[@]}" -cp "$CP" ApkSignerTool sign "$TMP/app-debug-aligned.apk" "$OUT/app-debug.apk" \
    "$ROOT/signing/stalker-pda-debug.jks" android androiddebugkey android "Android Debug" \
    > "$RESULTS/debug-signing.txt"
  java "${JAVA_EXPORT[@]}" -cp "$CP" ApkSignerTool verify "$OUT/app-debug.apk" \
    > "$RESULTS/debug-verification.txt"
}

build_release() {
  local key="$ROOT/signing/stalker-pda-release.jks"
  local pass_file="$ROOT/signing/release-password.txt"
  [[ -f "$key" && -f "$pass_file" ]] || {
    echo "Для release-сборки распакуйте материалы подписи в signing/: stalker-pda-release.jks и release-password.txt" >&2
    exit 1
  }
  prepare_variant release
  java -jar "$APKTOOL" b -f "$TMP/release" -o "$TMP/app-release-unsigned.apk"
  python3 "$ZIPALIGN" "$TMP/app-release-unsigned.apk" "$TMP/app-release-aligned.apk"
  local pass
  pass="$(cat "$pass_file")"
  java "${JAVA_EXPORT[@]}" -cp "$CP" ApkSignerTool sign "$TMP/app-release-aligned.apk" "$OUT/app-release.apk" \
    "$key" "$pass" stalkerpda "$pass" "STALKER PDA Release" \
    > "$RESULTS/release-signing.txt"
  java "${JAVA_EXPORT[@]}" -cp "$CP" ApkSignerTool verify "$OUT/app-release.apk" \
    > "$RESULTS/release-verification.txt"
}

[[ "$MODE" == "all" || "$MODE" == "debug" ]] && build_debug
[[ "$MODE" == "all" || "$MODE" == "release" ]] && build_release

echo "Готово:"
if [[ -f "$OUT/app-debug.apk" && ( "$MODE" == "all" || "$MODE" == "debug" ) ]]; then ls -lh "$OUT/app-debug.apk"; fi
if [[ -f "$OUT/app-release.apk" && ( "$MODE" == "all" || "$MODE" == "release" ) ]]; then ls -lh "$OUT/app-release.apk"; fi
exit 0
