/// ## Ревью: `Financify/Persistence/PersistentBankAccount.swift`
/// 
/// ## Критично
/// - **`@Model final class PersistentBankAccount: Sendable`**: как и с другими SwiftData-моделями, `Sendable` выглядит потенциально неверно и может скрывать проблемы конкурентности.
/// 
/// ## Важно
/// - **`currency: String`**: на доменном уровне тоже используется `String`. Это даёт гибкость, но повышает риск несогласованности (код/символ/локаль). В коде уже есть `Currency` enum — стоит определить, какой формат является “истиной” (ISO-код vs символ).
/// 
/// ## Предложения
/// - Убрать `Sendable`.
/// - Определить единый формат валюты (например, ISO 4217 код) и держать его в storage/domain, а символ получать через маппинг.
/// 

import Foundation
import SwiftData

@Model
final class PersistentBankAccount: Sendable {
    @Attribute(.unique)
    var id: Int
    var userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: Int,
        userId: Int,
        name: String,
        balance: Decimal,
        currency: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init(from domain: BankAccount) {
        self.init(
            id: domain.id,
            userId: domain.userId,
            name: domain.name,
            balance: domain.balance,
            currency: domain.currency,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
    
    func toDomain() -> BankAccount {
        BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
