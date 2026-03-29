# Errors.swift — Code Review

## Замечания

### 1. `TransactionsFileCacheError` — мёртвый код
`TransactionsFileCacheError` используется только в `TransactionsFileCache`, который сам не используется в приложении.

### 2. Отсутствие `LocalizedError` conformance
Ни `BankAccountServicesError`, ни `TransactionsFileCacheError` не реализуют `LocalizedError`. Когда ошибка попадает в `error.localizedDescription`, пользователь увидит нечитаемое системное описание вместо human-friendly сообщения.

### 3. Нет единого error-типа для сервисного слоя
`BankAccountServicesError` — единственный кастомный тип ошибок для сервисов. `TransactionsService` и `CategoriesService` не имеют своих ошибок и полагаются на `NetworkError` или стандартные `Error`. Стоит выработать единый подход.
