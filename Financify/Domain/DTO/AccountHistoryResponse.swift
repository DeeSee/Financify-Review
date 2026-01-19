/// ## Ревью: `Financify/Domain/DTO/AccountHistoryResponse.swift`
/// 
/// ## Важно
/// - `currentBalance: Decimal` и `history: [AccountHistory]` декодируются дефолтно. В проекте суммы и даты из API уже обрабатываются как строки (см. `BankAccount`, `TransactionResponse`), поэтому этот DTO в текущем виде не согласован с остальным сетевым контрактом без кастомного decode или `JSONDecoder` стратегий.
/// - Тип `AccountHistoryResponse` **нигде не используется**: в проекте нет эндпоинтов/вызовов “истории счета”, а сам тип встречается только в файле объявления.
/// 
/// ## Предложения
/// - Удалить как мёртвый код. При необходимости сохранить заготовку под будущий API — перенести тип в отдельную ветку/задачу, чтобы он не мешал поддержке основного контракта.
/// - Чтобы DTO работал с принятой в проекте сериализацией, добавить кастомный decode (строки → Decimal/Date) по аналогии с `TransactionResponse`.
/// 

import Foundation

struct AccountHistoryResponse: Codable {
    var accountId: Int
    var accountName: String
    var currency: String
    var currentBalance: Decimal
    var history: [AccountHistory]
}
