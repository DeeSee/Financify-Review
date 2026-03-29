# Transaction+ParseJSON.swift + Transaction+JsonObject.swift — Code Review

## Баги

### 1. Несовместимость `jsonObject` и `parse(jsonObject:)` с кастомным `Codable`
`Transaction.jsonObject` использует `JSONEncoder` → `JSONSerialization.jsonObject`. Кастомный `encode(to:)` в `Transaction` кодирует `amount` как строку и даты как ISO8601-строки.

`Transaction.parse(jsonObject:)` использует `JSONSerialization.data` → `JSONDecoder`. Кастомный `init(from:)` ожидает `amount` как строку и даты как ISO8601-строки.

Потенциальная проблема: `JSONSerialization.jsonObject` из `Data` может преобразовать строку `"1234.56"` обратно как `String`, но если по пути промежуточная сериализация что-то изменит (например, округлит), round-trip сломается. В целом этот путь работает, но это хрупкая цепочка: `Encodable → Data → [String:Any] → Data → Decodable`.

**Рекомендация:** Для round-trip тестирования лучше использовать `JSONEncoder`/`JSONDecoder` напрямую без промежуточного `JSONSerialization`.

### 2. Оба файла — мёртвый код
`jsonObject` используется только в `TransactionsFileCache.saveTo(jsonFile:)`, а `parse(jsonObject:)` — в `TransactionsFileCache.loadFrom(jsonFile:)`. Сам `TransactionsFileCache` не используется в приложении. Единственное место использования — юнит-тесты, но и там тестируется именно этот round-trip.
