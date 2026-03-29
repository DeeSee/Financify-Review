# TransactionsFileCache.swift — Code Review

## Замечания

### 1. Мёртвый код
`TransactionsFileCache` нигде не используется в приложении. Все данные транзакций идут через `TransactionsService` → SwiftData. Этот класс, вероятно, остался от ранней версии приложения (до перехода на SwiftData + сервер).

Закомментированные тестовые данные (строки 6–13) подтверждают, что это легаси.

**Рекомендация:** Удалить из проекта вместе с `Transaction+JsonObject.swift`, `Transaction+ParseJSON.swift`, `Transaction+ParseCSV.swift`, `TransactionsFileCacheError`.

### 2. `loadFrom(csvFile:)` и `loadFrom(jsonFile:)` — перезаписывают данные
Оба метода полностью заменяют `transactions` на загруженные данные. Нет merge-логики. Если были добавлены транзакции в памяти, они будут потеряны.

### 3. `Task.detached(priority: .background)` для файлового I/O
Использование `Task.detached` для чтения/записи файлов — правильный подход, но:
- Нет обработки отмены (`Task.isCancelled`).
- Для маленьких файлов overhead от создания Task превышает пользу.
