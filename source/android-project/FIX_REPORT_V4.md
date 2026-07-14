# STALKER PDA Android — Fix v4

## Подтверждённая причина сбоя

Устройство показало:

`java.lang.NoSuchMethodError: No virtual method setContentAccess(Z)V in class android.webkit.WebSettings`

В `MainActivity.smali` был ошибочно вызван несуществующий метод:

```smali
Landroid/webkit/WebSettings;->setContentAccess(Z)V
```

Корректный Android API:

```smali
Landroid/webkit/WebSettings;->setAllowContentAccess(Z)V
```

Из-за ошибки приложение проходило установку, но останавливалось во время `onCreate()` до загрузки интерфейса.

## Исправление

- заменён только ошибочный вызов WebSettings;
- сохранён package name `by.smorhon.stalkerpda.v3`, поэтому release v4 устанавливается поверх release v3;
- версия повышена до `1.0.3`, versionCode — до `10003`;
- веб-приложение, карта, GPS, камера, QR, метки, заметки и формат данных не менялись.

## Проверки

- APKTool build: успешно;
- zip alignment: успешно;
- APK Signature Scheme v2: успешно;
- release certificate SHA-256 не изменён;
- повторное декодирование APK: успешно;
- в итоговом DEX найден `setAllowContentAccess`, старого `setContentAccess` нет;
- все catch-обработчики начинаются с `move-exception`;
- три встроенных JavaScript-блока проходят `node --check`;
- дублирующихся HTML id нет;
- битых `byId()`-ссылок нет;
- внешних runtime-ресурсов нет.

## Ограничение проверки

Установка и запуск на физическом Android-устройстве в среде сборки недоступны. Исправление напрямую соответствует диагностике, полученной на реальном устройстве.
