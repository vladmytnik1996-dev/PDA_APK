# Fixed v6 — Immersive fullscreen

## Изменение

Android-оболочка переведена в устойчивый immersive sticky fullscreen:

- скрывается верхняя строка состояния с часами, сетью и уведомлениями;
- скрывается нижняя системная навигационная панель;
- краткий свайп от края временно показывает системные панели;
- после возврата фокуса, разрешений, выбора файлов и возобновления Activity полноэкранный режим восстанавливается;
- добавлена поддержка display cutout через `shortEdges` на Android 9+;
- веб-интерфейс учитывает `safe-area-inset-top` и `safe-area-inset-bottom`.

## Версия

- release package: `by.smorhon.stalkerpda.v3`;
- debug package: `by.smorhon.stalkerpda.v6.debug`;
- versionName: `1.0.5`;
- versionCode: `10005`.

## Ограничение Android

В immersive-режиме пользователь всегда может временно показать системные панели системным жестом от края. Это обязательное поведение Android и не должно блокироваться приложением.
