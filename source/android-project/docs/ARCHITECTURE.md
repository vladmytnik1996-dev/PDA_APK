# Архитектура Android-версии

## Почему выбран нативный WebView

Исходный продукт является автономным однофайловым HTML-приложением без npm-проекта, сборщика, серверного API и внешних runtime-зависимостей. Для такого входа безопаснее минимальная нативная оболочка WebView: она не меняет бизнес-логику SPA и не добавляет лишний JavaScript-фреймворк.

Capacitor рассматривался как приоритетный вариант, однако в доступной среде отсутствовал готовый Android SDK/Gradle toolchain. Поэтому применён разрешённый техническим заданием резервный вариант: нативная Android Activity и локальный WebView. APK собирается локально через APKTool и подписывается библиотекой apksig.

## Поток загрузки

1. `MainActivity` создаёт WebView.
2. WebView загружает `https://localhost/index.html`.
3. `LocalWebViewClient.shouldInterceptRequest()` возвращает файл `assets/www/index.html` непосредственно из APK.
4. Никакого DNS-запроса или сетевого обращения к localhost не происходит.
5. Secure-origin позволяет Geolocation API и `getUserMedia` работать через стандартные разрешения WebView/Android.

## Мосты Android ↔ JavaScript

### Экспорт JSON

В Android-среде SPA вызывает:

```javascript
window.AndroidPda.saveTextFile(filename, json)
```

Android открывает `ACTION_CREATE_DOCUMENT` и записывает данные через `ContentResolver`. В браузере сохранён старый способ скачивания через Blob.

### Системная кнопка «Назад»

Activity вызывает `window.pdaHandleAndroidBack()`. JavaScript возвращает `true`, если закрыл QR-окно, окно метки, панель задания, режим постановки метки или GPS-привязки, либо вернулся на карту. Если обработать нечего, Android использует двойное нажатие для выхода.

## Разрешения

Manifest содержит только:

- `CAMERA`;
- `ACCESS_FINE_LOCATION`;
- `ACCESS_COARSE_LOCATION`.

`INTERNET` отсутствует. Камера и GPS объявлены как необязательные hardware features, поэтому приложение можно установить на устройство без этих модулей, но соответствующие функции будут недоступны.

## Хранилище

- задачи, заметки, GPS-калибровка и настройки: `localStorage`;
- изображение карты: IndexedDB;
- все данные изолированы внутри sandbox приложения;
- удаление приложения обычно удаляет эти локальные данные;
- данные браузерной HTML-версии автоматически не переносятся в APK, поскольку это другой storage origin и sandbox. Для переноса нужно использовать JSON-экспорт/импорт.

## Безопасность WebView

- внешняя сеть не требуется и permission `INTERNET` отсутствует;
- cleartext HTTP отключён;
- file access и universal file URL access отключены;
- mixed content запрещён;
- WebView debugging отключён;
- сторонние cookies отключены;
- неизвестные URL не загружаются внутри WebView, а передаются внешнему обработчику Android;
- JavaScript bridge доступен только локальному документу, а локальный WebViewClient не обслуживает произвольные пути.
