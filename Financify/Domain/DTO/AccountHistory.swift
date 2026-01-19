/// ## Ревью: `Financify/Domain/DTO/AccountHistory.swift`
/// 
/// ## Важно
/// - `Date` и вложенные структуры декодируются дефолтно. В проекте даты из API уже парсятся вручную из ISO8601-строк (см. `BankAccount`, `TransactionResponse`), поэтому этот DTO в текущем виде не согласован с остальным сетевым контрактом без `dateDecodingStrategy` или кастомного `init(from:)`.
/// - `changeType` хранится как `String` — лучше типизировать enum’ом, если набор значений конечный.
/// - Тип `AccountHistory` **не используется в приложении**: единственные упоминания — его объявление и поле `history` в `AccountHistoryResponse` (эндпоинтов/вызовов “истории счета” в проекте нет).
/// 
/// ## Предложения
/// - Удалить как мёртвый код. При необходимости сохранить заготовку под будущий API — перенести тип в отдельную ветку/задачу, чтобы он не мешал поддержке основного контракта.
/// - Чтобы этот DTO работал с принятой в проекте сериализацией, добавить кастомный decode для дат/Decimal (по аналогии с `TransactionResponse`).
/// - Сделать `changeType` enum’ом.
/// 

import Foundation

struct AccountHistory: Codable, Identifiable {
    var id: Int
    var accountId: Int
    var changeType: String
    var previousState: AccountState
    var newState: AccountState
    var changeTimestamp: Date
    var createdAt: Date
}
