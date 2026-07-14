# Ручной запуск HTML на Android через localhost

Этот режим нужен только тем, кто запускает веб-версию без APK. Для GPS и камеры страницу необходимо открывать **через localhost**, а не через `file://` или `content://`.

## Termux

1. Установите Termux из F-Droid или официальных релизов Termux.
2. Распакуйте папку `web` в память телефона.
3. В Termux выполните:

```bash
pkg update -y
pkg install python -y
termux-setup-storage
cd ~/storage/downloads/ПАПКА_РЕЛИЗА/web
bash start-android.sh
```

4. Не закрывая Termux, откройте Chrome и введите **точно**:

```text
http://localhost:8080/
```

5. Нажмите GPS или QR-сканер и разрешите геолокацию/камеру.

## Повторный запуск

```bash
cd ~/storage/downloads/ПАПКА_РЕЛИЗА/web
bash start-android.sh
```

## Если порт занят

```bash
python server.py --port 8090
```

Затем откройте `http://localhost:8090/`.

## Важно

- Не открывайте `index.html` напрямую из файлового менеджера.
- Адрес должен начинаться с `http://localhost:`.
- Сервер слушает только `127.0.0.1`, поэтому не публикует приложение в локальную сеть.
- Карта, привязка, метки и заметки сохраняются отдельно в хранилище браузера.
