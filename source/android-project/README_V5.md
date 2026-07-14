# КПК Зоны 1.0.4 — fixed v5

## Установка

Основной файл: `stalker-pda-app-release-fixed-v5.apk`.

Release v5 является штатным обновлением v4:

- пакет: `by.smorhon.stalkerpda.v3`;
- версия: `1.0.4`;
- versionCode: `10004`;
- сертификат подписи не изменён.

Поэтому v5 следует устанавливать поверх v4 — локальные данные приложения должны сохраниться. Не удаляйте v4 без предварительного экспорта резервной копии.

Debug v5 использует отдельный пакет `by.smorhon.stalkerpda.v5.debug` и устанавливается рядом с release.

## Установка через ADB

```bash
adb install -r stalker-pda-app-release-fixed-v5.apk
```

Запуск:

```bash
adb shell am start -n by.smorhon.stalkerpda.v3/by.smorhon.stalkerpda.MainActivity
```

Лог запуска:

```bash
adb logcat -c
adb shell am force-stop by.smorhon.stalkerpda.v3
adb shell am start -n by.smorhon.stalkerpda.v3/by.smorhon.stalkerpda.MainActivity
adb logcat AndroidRuntime:E chromium:E System.err:E '*:S'
```

## Повторная сборка

Debug:

```bash
./build.sh debug
```

Release требует прежние `stalker-pda-release.jks` и `release-password.txt` в каталоге `signing/`:

```bash
./build.sh release
```

Полный аудит:

```bash
./verify.sh
```

`verify.sh` запускает HTML/JS-аудит, Smali-аудит, сборку, бинарную проверку APK и доступные DOM-smoke-тесты.
