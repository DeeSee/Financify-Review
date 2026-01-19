/// ## Ревью: `Financify/Domain/DTO/AccountCreateRequest.swift`
/// 
/// ## Важно
/// - В отличие от `AccountUpdateRequest`/`TransactionRequest`, этот DTO **не переопределяет `encode(to:)`**.
///   - `Decimal` по умолчанию кодируется как number, тогда как в других местах проект ожидает строку (`"1234.56"`).
/// - Этот DTO **нигде не используется** в проекте (нет ссылок на `AccountCreateRequest` и нет логики создания счета), но в текущем виде он не согласован с принятой в проекте сериализацией `Decimal` (строковый формат).
/// 
/// ## Предложения
/// - Унифицировать формат: либо везде числа строкой, либо везде числом (и настроить API/decoder соответствующе).
/// - Привести к принятому в проекте формату (“Decimal как строка”) — добавить кастомный `encode(to:)` как в `AccountUpdateRequest`.
/// 

import Foundation

struct AccountCreateRequest: Encodable {
    var name: String
    var balance: Decimal
    var currency: String
}
