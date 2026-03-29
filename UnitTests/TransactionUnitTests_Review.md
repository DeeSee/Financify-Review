# TransactionUnitTests.swift — Code Review

## Баги

### 1. Тесты тестируют мёртвый код
Все тесты проверяют `Transaction.jsonObject` и `Transaction.parse(jsonObject:)` — методы, которые используются только в `TransactionsFileCache`, а тот не используется в приложении. Тесты не покрывают актуальную функциональность (сервисы, ViewModel'ы, синхронизацию).

### 2. `testJSONObject_ReturnsDictionaryMirror` — проверяет `amount` как `Double` (строки 31–34)
```swift
let amount = try XCTUnwrap(dict["amount"] as? Double)
```
Но `Transaction.encode` кодирует `amount` как **строку** (`NSDecimalNumber(decimal:).stringValue`). После `JSONSerialization.jsonObject`, строка `"1234.56"` останется строкой, а не станет `Double`. Тест упадёт на `as? Double`.

**Однако**: `JSONSerialization` может представить JSON-строку как `NSString`, и `as? Double` вернёт `nil`. Тест может падать.

Аналогично `transactionDate` проверяется как `Double` (строки 36–39), но кодируется как ISO8601-строка.

**Рекомендация:** Проверять `amount` как `String` и `transactionDate` как `String`.

### 3. `testParse_WithMissingRequiredKey_ReturnsNil` — `comment` не optional (строка 91)
В `Transaction`, `comment` — это `String?` (optional). В `init(from:)` используется `decodeIfPresent`. Поэтому отсутствие ключа `comment` **не вызовет ошибку** — `comment` будет `nil`. Тест `XCTAssertNil(Transaction.parse(jsonObject: jsonNoComment))` на строке 116 **может пройти или упасть** в зависимости от того, как `JSONSerialization` обработает словарь без `comment`.

## Замечания

### 4. Покрытие тестами крайне низкое
Весь тестовый файл покрывает только один тип (`Transaction`) и только его JSON round-trip. Нет тестов для:
- Сервисов (`BankAccountService`, `TransactionsService`, `CategoriesService`)
- Синхронизации (`SynchronizationService`)
- ViewModel'ов
- Кастомных `Codable` реализаций для DTO
- Edge cases (пустой баланс, неизвестная валюта, оффлайн-сценарии)

### 5. Нет моков для зависимостей
Сервисы не имеют протоколов для `NetworkClient`, что делает невозможным unit-тестирование без реального сервера.
