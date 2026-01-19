/// ## Ревью: `Financify/Domain/DTO/AccountState.swift`
/// 
/// ## Важно
/// - `balance: Decimal` декодируется дефолтно. В проекте баланс/суммы из API парсятся вручную из строк (см. `BankAccount`, `AccountBrief`, `TransactionResponse`), поэтому этот DTO в текущем виде не согласован с остальным сетевым контрактом.
/// - Тип `AccountState` **нигде не используется** в проекте (кроме вложенных полей в `AccountHistory`).
/// 
/// ## Предложения
/// - Унифицировать с `BankAccount`/`AccountBrief`: либо везде кастомный decode, либо общий `JSONDecoder` с корректной стратегией.
/// 

import Foundation

struct AccountState: Codable, Identifiable {
    var id: Int
    var name: String
    var balance: Decimal
    var currency: String
}
