# AccountResponse.swift — Code Review

## Замечания

### 1. `Decodable`, но не `Codable` (строка 3)
`AccountResponse` реализует только `Decodable`. При этом поля `balance`, `createdAt`, `updatedAt` — кастомных типов, требующих специальной десериализации (строка-число для Decimal, ISO8601 для дат). **Но кастомного `init(from:)` нет.** Стандартный синтезированный декодер попытается декодировать `balance` как `Decimal` напрямую (а сервер шлёт строку) и `createdAt`/`updatedAt` как `Date` (а сервер шлёт ISO8601-строку).

Это **баг**: декодирование `AccountResponse` будет падать в рантайме, если сервер шлёт `balance` как строку и даты как строки (а судя по всем остальным DTO — именно так).

**Рекомендация:** Добавить кастомный `init(from decoder:)` аналогично `BankAccount`, `TransactionResponse` и другим DTO.

### 2. `incomeStats` / `expenseStats` не используются
Поля `incomeStats: [StatItem]` и `expenseStats: [StatItem]` объявлены, но нигде в проекте не читаются. Если они нужны — стоит использовать; если нет — убрать, чтобы не усложнять модель.
