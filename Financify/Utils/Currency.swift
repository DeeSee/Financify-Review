/// ## Ревью: `Financify/Utils/Currency.swift`
/// 
/// ## Критично
/// - **`init(jsonTitle:)` делает `fatalError` для неизвестной валюты**. При получении нового/неизвестного кода валюта приведёт к крэшу приложения. Здесь лучше:
///   - `init?(jsonTitle:)` (optional),
///   - либо `throws`,
///   - либо `.unknown(code: String)` как case.
/// 
/// ## Важно
/// - **Смешение “кода” и “символа”**:
///   - `jsonTitle` — ISO‑код (RUB/USD/EUR).
///   - `rawValue` — символ (₽/$/€).
///   - Важно не использовать `rawValue` там, где ожидается ISO‑код (например, формат `.currency(code:)` ожидает `RUB`, а не `₽`).
/// 
/// ## Предложения
/// - Сделать единый “источник истины”: хранить валюту как ISO‑код, а символ/название получать вычисляемо.
/// - Добавить fallback‑поведение для неизвестных валют (не падать).
/// 

enum Currency: String, CaseIterable {
    case rub = "₽"
    case usd = "$"
    case eur = "€"
    
    var currencyTitle: String {
        switch self {
        case .rub: return "Российский рубль ₽"
        case .usd: return "Доллар США $"
        case .eur: return "Евро €"
        }
    }
    
    var jsonTitle: String {
        switch self {
        case .rub: return "RUB"
        case .usd: return "USD"
        case .eur: return "EUR"
        }
    }
    
    init(jsonTitle: String) {
        switch jsonTitle {
        case Currency.rub.jsonTitle: self = .rub
        case Currency.usd.jsonTitle: self = .usd
        case Currency.eur.jsonTitle: self = .eur
        default: fatalError("Неподдерживаемая валюта \(jsonTitle)")
        }
    }
}
