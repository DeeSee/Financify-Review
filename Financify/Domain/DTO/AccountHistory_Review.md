# AccountHistory.swift + AccountHistoryResponse.swift — Code Review

## Замечания

### 1. Отсутствует кастомный `Codable`
`AccountHistory` и `AccountHistoryResponse` реализуют `Codable` через автосинтез. Но `changeTimestamp`, `createdAt` (в `AccountHistory`) и `currentBalance` (в `AccountHistoryResponse`) — это `Date` и `Decimal`, которые сервер, судя по остальным DTO, присылает как строки.

Аналогично `AccountResponse` — стандартный декодер не справится с форматом сервера.

### 2. Неиспользуемые типы
Ни `AccountHistory`, ни `AccountHistoryResponse` нигде в проекте не используются. Это мёртвый код.

### 3. `AccountState` — тоже неиспользуемый тип
`AccountState` используется только внутри `AccountHistory`, который сам не используется. При этом `AccountState.balance: Decimal` тоже потребует кастомного `Codable` для строкового формата.
