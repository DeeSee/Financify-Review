# TransactionsService.swift — Code Review

## Баги

### 1. `saveToAdd` — `CodingUserInfoKey` не используется кодером (строки 180–193)
```swift
let userInfo: [String: String] = ["tempId": String(temporaryId)]
let encoder = JSONEncoder()
encoder.userInfo[CodingUserInfoKey(rawValue: "tempId")!] = userInfo
let payload = try encoder.encode(requestWithTempId)
```
Кастомный `userInfo` устанавливается в encoder, но `TransactionRequest.encode(to:)` его **не читает**. В итоге payload не содержит `tempId`, и при синхронизации невозможно связать серверный ответ с локальной транзакцией.

Локальная транзакция с отрицательным `id` (строка 166) останется в базе после синхронизации, потому что `updateLocalStore(with:)` удаляет все и заново вставляет серверные данные — но только при следующем полном refresh. До этого момента возможны дубликаты.

### 2. Временный ID — коллизии (строка 166)
```swift
let temporaryId = -Int(Date().timeIntervalSince1970)
```
`timeIntervalSince1970` имеет точность до секунды после преобразования в `Int`. Если пользователь быстро создаст две транзакции в одну секунду, id совпадут, и `@Attribute(.unique)` в `PersistentTransaction` вызовет конфликт.

**Рекомендация:** Использовать более уникальный id (например, `Int.random(in: Int.min..<0)`).

### 3. `getAllTransactions` с замыканием `filter` — проблема с Sendable (строка 6)
```swift
func getAllTransactions(by accountId: Int, with filter: (Transaction) -> Bool) async throws -> [Transaction]
```
Замыкание `(Transaction) -> Bool` не помечено `@Sendable`. В Swift 6 strict concurrency это ошибка — замыкание передаётся через actor boundary.

### 4. `fetchLocalTransactions` не применяет POST-операции из backup (строки 86–118)
Метод обрабатывает только `PUT`-операции из backup, но `POST`-операции (добавление транзакций) игнорируются. Транзакции, добавленные оффлайн, уже есть в локальном SwiftData (вставлены в `saveToAdd`), поэтому они появятся — но без учёта возможных последующих PUT-операций к ним в очереди (т.к. `parseId` из POST-эндпоинта не извлечёт id).

### 5. `updateLocalStore` — удаляет ВСЕ транзакции (строка 128)
```swift
try modelContext.delete(model: PersistentTransaction.self)
```
При загрузке с сервера удаляются **все** локальные транзакции, включая те, что были добавлены оффлайн с отрицательным id. Если синхронизация ещё не прошла, оффлайн-транзакции будут потеряны из UI (хотя операция в backup останется).
