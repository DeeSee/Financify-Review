/// ## Ревью: `Financify/Domain/BankAccount.swift`
/// 
/// ## Критично
/// - **Парсинг `balance` через `Decimal(string:)` зависит от локали** (см. `Transaction_Review.md`). На ru‑локали значения вида `"1234.56"` теряют дробную часть.
/// 
/// ## Важно
/// - **`encode(to:)` использует `String(describing: balance)`**:
///   - Это не гарантирует стабильный формат для API.
///   - В других местах уже используется `NSDecimalNumber(decimal:).stringValue` — лучше унифицировать.
/// - `currency` хранится как `String`, а в UI есть `Currency` enum → легко получить несогласованность (ISO код vs символ).
/// 
/// ## Предложения
/// - Использовать `NSDecimalNumber(decimal: balance).stringValue` при кодировании.
/// - Парсить balance с `locale: en_US_POSIX`.
/// - Рассмотреть хранение валюты как ISO‑кода на доменном уровне.
/// 

import Foundation

struct BankAccount: Codable, Identifiable {
    let id: Int
    let userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
}

extension BankAccount {
    func convertToAccountUpdateRequest() -> AccountUpdateRequest {
        return AccountUpdateRequest(
            name:       self.name,
            balance:    self.balance,
            currency:   self.currency
        )
    }
}

extension BankAccount {
    private enum CodingKeys: String, CodingKey {
        case id, userId, name, balance, currency, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = try c.decode(Int.self,    forKey: .id)
        userId = try c.decode(Int.self,    forKey: .userId)
        name   = try c.decode(String.self, forKey: .name)

        let balStr = try c.decode(String.self, forKey: .balance)
        guard let bal = Decimal(string: balStr) else {
            throw DecodingError.dataCorruptedError(
                forKey: .balance, in: c,
                debugDescription: "balance должен быть строкой-числом"
            )
        }
        balance = bal

        currency = try c.decode(String.self, forKey: .currency)

        let createdStr = try c.decode(String.self, forKey: .createdAt)
        let updatedStr = try c.decode(String.self, forKey: .updatedAt)
        guard
            let created = ISO8601DateFormatter.shmr.dateNormalized(from: createdStr),
            let updated = ISO8601DateFormatter.shmr.dateNormalized(from: updatedStr)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt, in: c,
                debugDescription: "createdAt/updatedAt неверного формата"
            )
        }
        createdAt = created
        updatedAt = updated
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,     forKey: .id)
        try c.encode(userId, forKey: .userId)
        try c.encode(name,   forKey: .name)
        try c.encode(String(describing: balance), forKey: .balance)
        try c.encode(currency, forKey: .currency)

        try c.encode(
            ISO8601DateFormatter.shmr.string(from: createdAt),
            forKey: .createdAt
        )
        try c.encode(
            ISO8601DateFormatter.shmr.string(from: updatedAt),
            forKey: .updatedAt
        )
    }
}
