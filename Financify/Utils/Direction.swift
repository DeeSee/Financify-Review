/// ## Ревью: `Financify/Utils/Direction.swift`
/// 
/// ## Важно
/// - **`.outcome` как “расход”**: в английском `outcome` чаще значит “исход/результат”, а не “трата”. Для ясности лучше `expense` (или `outgoing`).
/// - **UI‑строки в enum** (`title`, `tabTitle`) жёстко пришиты к модели. Это удобно, но снижает гибкость локализации/дизайна. Часто лучше держать строки ближе к UI (или через локализацию).
/// 
/// ## Предложения
/// - Переименовать кейс (если возможно без больших миграций).
/// - Вынести отображаемые строки в локализацию.
/// 

enum Direction: String, Codable {
    case income
    case outcome
    
    var title: String {
        switch self {
            
        case .income:
            return "Доходы сегодня"
            
        case .outcome:
            return "Расходы сегодня"
        }
    }
    
    var tabTitle: String {
        switch self {
            
        case .income:
            return "Доходы"
            
        case .outcome:
            return "Расходы"
        }
    }
}
