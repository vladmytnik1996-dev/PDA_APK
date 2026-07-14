# Автоматические проверки релиза 1.0.6

Полный отчёт находится в [`../TEST_REPORT.md`](../TEST_REPORT.md).

В папке `results/` сохранены компактные результаты:

- статического аудита HTML/JavaScript;
- аудита Smali/DEX-структуры;
- проверки подписи release APK.

Тестовые сценарии и исходный код проверок находятся в `source/android-project/tools/`:

- `static_audit.py`;
- `smali_audit.py`;
- `web_dom_smoke.py`;
- `web_smoke_test.py`;
- `camera_dom_smoke.py`;
- `camera_smoke_test.py`;
- `gps_calibration_qr_dom.py`.

Основной запуск статических и DOM-тестов: `source/android-project/verify.sh`. Для release-сборки необходим приватный keystore, который не публикуется в GitHub.
