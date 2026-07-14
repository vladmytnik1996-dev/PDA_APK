# КПК Зоны — Android-проект

Нативная Android-оболочка для автономного одностраничного приложения в стиле КПК S.T.A.L.K.E.R. Исходное SPA встроено в APK и открывается в защищённом локальном origin `https://localhost/`; внешний веб-сервер и интернет для работы приложения не требуются.

## Готовые сборки

После сборки APK находятся в:

```text
build/outputs/app-release.apk
build/outputs/app-debug.apk
```

Release и debug имеют разные идентификаторы, поэтому могут быть установлены одновременно:

- release: `by.smorhon.stalkerpda`
- debug: `by.smorhon.stalkerpda.debug`

## Архитектура

- Android Activity с системным `WebView`.
- SPA целиком находится в `android/apktool-app/assets/www/index.html`.
- Локальные ресурсы выдаются из APK через `WebViewClient` по адресу `https://localhost/index.html`.
- Android-разрешения камеры и геолокации запрашиваются только при использовании соответствующих функций.
- Выбор карты, QR-изображения и JSON выполняется через системный выбор файлов.
- Экспорт JSON выполняется через системный диалог создания документа.
- `localStorage`, IndexedDB и состояние WebView сохраняются в приватном каталоге приложения.
- Системная кнопка «Назад» сначала закрывает внутренние режимы и модальные окна, затем требует повторного нажатия для выхода.

## Требования для повторной сборки

- Linux, macOS или WSL с Bash;
- Java/JDK 17 или новее;
- Python 3;
- `keytool`, входящий в JDK.

Gradle и Android SDK для этой конкретной сборочной схемы не требуются: в `tools/lib/` уже находятся APKTool и библиотека проверки/подписи APK. Для установки на телефон через компьютер нужен отдельно установленный `adb` из Android Platform Tools.

## Сборка debug

```bash
chmod +x build.sh
./build.sh debug
```

Debug-keystore создаётся автоматически, если отсутствует.

## Сборка release

Сначала поместите в папку `signing/`:

```text
signing/stalker-pda-release.jks
signing/release-password.txt
```

Затем выполните:

```bash
./build.sh release
```

Сборка обоих вариантов:

```bash
./build.sh all
```

## Установка через ADB

Включите «Для разработчиков» и «Отладку по USB» на Android, подключите телефон и выполните:

```bash
adb devices
adb install -r build/outputs/app-release.apk
```

Запуск из командной строки:

```bash
adb shell am start -n by.smorhon.stalkerpda/.MainActivity
```

Логи приложения:

```bash
adb logcat --pid=$(adb shell pidof -s by.smorhon.stalkerpda)
```

Удаление:

```bash
adb uninstall by.smorhon.stalkerpda
```

## Обновление приложения

Для установки обновления поверх прежней release-версии необходимо одновременно сохранить:

1. тот же `applicationId`;
2. тот же release-keystore;
3. тот же alias ключа;
4. увеличить `versionCode`.

Потеря release-keystore делает выпуск совместимого обновления с прежней подписью невозможным. Подробности находятся в `SIGNING_SECURITY.md`.

## Структура проекта

```text
android/apktool-app/       Android manifest, ресурсы и smali-код оболочки
web-source/                исходный и адаптированный HTML
signing/                   материалы подписи; release-секреты не публиковать
tools/                     сборочные, проверочные и браузерные тесты
tools/lib/                 локальные зависимости сборки
test-results/              результаты выполненных проверок
build/outputs/             готовые APK
docs/                      техническое описание архитектуры
```

## Проверка

```bash
python3 tools/static_audit.py
./build.sh all
```

Полный фактический статус тестов, включая то, что не удалось выполнить без Android-устройства, указан в `TESTING_REPORT.md`.
