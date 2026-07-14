# КПК Зоны — Android fixed v4

## Установка обновления

### Release

Установите `stalker-pda-app-release-fixed-v4.apk` поверх установленной release v3.

Package name сохранён:

`by.smorhon.stalkerpda.v3`

Подпись release сохранена, версия повышена до 1.0.3, поэтому удалять v3 обычно не требуется.

### Debug

`stalker-pda-app-debug-fixed-v4.apk` устанавливается поверх debug v3 с package name:

`by.smorhon.stalkerpda.v3.debug`

## Если Android не предлагает обновление

Удалите только соответствующую старую ветку:

- для release — старое приложение «КПК Зоны» v3;
- для debug — «КПК Зоны (Debug)» v3.

Удаление приложения очищает его локальные данные. Перед удалением экспортируйте резервную копию из вкладки «Данные», если приложение доступно.

## Сборка

```bash
chmod +x build.sh verify.sh
./build.sh all
./verify.sh
```

Для release требуются прежние файлы подписи в `signing/`:

- `stalker-pda-release.jks`
- `release-password.txt`
