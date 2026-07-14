# Отчёт fixed v6 — полноэкранный режим

## Запрос

Убрать мешающие системные значки Android в верхней части экрана и использовать всю площадь дисплея.

## Реализация

1. В тему приложения добавлен `android:windowFullscreen=true`, поэтому верхняя строка скрывается уже на стартовом окне.
2. Добавлен единый метод `hideSystemUi()` с флагами:
   - `SYSTEM_UI_FLAG_FULLSCREEN`;
   - `SYSTEM_UI_FLAG_HIDE_NAVIGATION`;
   - `SYSTEM_UI_FLAG_IMMERSIVE_STICKY`;
   - layout-флаги для предотвращения скачка интерфейса.
3. Полноэкранный режим повторно применяется:
   - после `setContentView`;
   - в `onResume`;
   - при восстановлении фокуса окна через `onWindowFocusChanged`.
4. Для Android 9+ добавлен `windowLayoutInDisplayCutoutMode=shortEdges`.
5. Для Android 10+ отключены контрастные системные scrim-слои.
6. В HTML добавлен `safe-area-inset-top`; существующий `safe-area-inset-bottom` сохранён.

## Совместимость

- release package сохранён: `by.smorhon.stalkerpda.v3`;
- release certificate сохранён;
- обновление устанавливается поверх v5;
- формат localStorage/IndexedDB не изменён;
- карта, GPS, QR, камера, метки и заметки не изменялись.

## Автоматические проверки

- `SMALI_AUDIT_OK`: 7 классов, 38 методов, 6 catch-обработчиков;
- debug и release APK собраны заново;
- обе APK декодированы и прошли бинарный аудит;
- v2-подпись обеих APK действительна;
- release certificate SHA-256 не изменился;
- все три JavaScript-блока прошли `node --check`;
- HTML: нет дублирующихся ID и битых `byId()`;
- WEB DOM smoke test: пройден;
- CAMERA DOM smoke test: пройден;
- ZIP/CRC: пройдено.

## Ограничение тестовой среды

Физический запуск immersive-режима на Android в контейнере невозможен из-за отсутствия Android-эмулятора или подключённого смартфона. Реализация использует стабильный API, доступный начиная с Android 4.4, при minSdk приложения 24.
