# BankAccount.swift — Code Review

## Баги

### 1. `String(describing: balance)` при кодировании (строка 65)
```swift
try c.encode(String(describing: balance), forKey: .balance)
```
`String(describing:)` для `Decimal` может давать результат, зависящий от локали и внутреннего представления. В отличие от `NSDecimalNumber(decimal:).stringValue`, который всегда даёт точку как десятичный разделитель, `String(describing:)` не гарантирует единообразный формат.

Во всех остальных местах проекта (AccountBrief, AccountUpdateRequest, Transaction, TransactionRequest) используется `NSDecimalNumber(decimal:).stringValue`. Здесь — несогласованность.

**Рекомендация:** Заменить на `NSDecimalNumber(decimal: balance).stringValue` для единообразия.

## Замечания

### 2. Неконсистентность `let` vs `var` для полей
`id` и `userId` объявлены как `let`, а `name`, `balance`, `currency`, `createdAt`, `updatedAt` — как `var`. Если модель приходит с сервера и `id`/`userId` неизменяемы — это логично, но `createdAt` тоже не должен меняться после создания.

### 3. Отсутствие `memberwise init`
Из-за кастомного `Codable` (через extension) автоматический memberwise init недоступен. При этом `PersistentBankAccount.toDomain()` вызывает `BankAccount(id:userId:name:balance:currency:createdAt:updatedAt:)` — значит где-то есть неявный init через Codable или через синтезированный. Стоит добавить явный init для ясности.

### 4. `convertToAccountUpdateRequest()` — именование
Название метода длинное и процедурное. В Swift принято использовать computed property или метод вида `toUpdateRequest()` / просто `var updateRequest: AccountUpdateRequest`.
