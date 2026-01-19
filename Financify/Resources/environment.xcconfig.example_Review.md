## Ревью: `Financify/Resources/environment.xcconfig.example`

## Важно
- **Хорошо, что ключ вынесен в `.xcconfig`** и есть пример.
- Стоит убедиться, что реальный `environment.xcconfig` (без `.example`) **исключён из VCS** (gitignore) и не утечёт.

## Предложения
- В этом же механизме удобно держать и **`BASE_URL`** (и прочие env‑параметры), чтобы не хардкодить `APIEndpoint.baseURL` в коде.
- Добавить краткую инструкцию в README:
  - где создать `environment.xcconfig`,
  - как подключить в Build Settings,
  - как проверить, что `API_KEY` реально попал в `Info.plist`.

