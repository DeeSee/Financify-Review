/// ## Ревью: `Financify/Domain/DTO/AccountResponse.swift`
/// 
/// ## Важно
/// - DTO использует `Decimal` и `Date` с дефолтным `Codable`, без кастомного парсинга.
///   - В проекте баланс/даты из API парсятся вручную из строк (см. `BankAccount`, `TransactionResponse`), поэтому этот DTO в текущем виде будет **декодироваться с ошибкой** при использовании того же контракта.
///   - Тип `AccountResponse` **нигде не используется**: загрузка счетов в `BankAccountService` декодит `.accountsGET` в `[BankAccount]`.
/// 
/// ## Предложения
/// - Удалить как мёртвый код. При необходимости сохранить заготовку под другой эндпоинт — перенести тип в отдельную ветку/задачу, чтобы он не мешал поддержке основного контракта.
/// - Чтобы использовать этот DTO с текущим контрактом проекта, реализовать кастомный `init(from:)` как в `BankAccount`/`TransactionResponse`.
/// 

import Foundation

struct AccountResponse: Decodable, Identifiable {
    var id: Int
    var name: String
    var balance: Decimal
    var currency: String
    var incomeStats: [StatItem]
    var expenseStats: [StatItem]
    var createdAt: Date
    var updatedAt: Date
}
