/// ## Ревью: `Financify/Domain/DTO/StatItem.swift`
/// 
/// ## Важно
/// - `amount: Decimal` декодируется дефолтно — если API отдаёт строкой, будет несовместимость без стратегии decoder.
/// - `emoji` хранится как `String`; если дальше в UI хочется `Character`, стоит определить единый формат (и обработку пустых/некорректных строк).
/// 
/// ## Предложения
/// - Уточнить контракт API по типу `amount` (строка/число) и унифицировать DTO.
/// 

import Foundation

struct StatItem: Codable {
    var categoryId: Int
    var categoryName: String
    var emoji: String
    var amount: Decimal
}
