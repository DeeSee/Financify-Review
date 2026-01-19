/// ## Ревью: `Financify/Utils/SortOption.swift`
/// 
/// ## Важно
/// - **`rawValue` используется как UI‑строка**. Если появится локализация/смена языка, удобнее держать отдельный `titleKey`/`localizedTitle`, а не хранить человеко‑читаемый текст в `rawValue`.
/// - **Иконки про рубль (`rublesign.circle*`)**:
///   - Даже если выбран USD/EUR, сортировка “по сумме” будет показывать рубль.
///   - Лучше использовать нейтральные символы (`arrow.up/arrow.down`, `number`, `line.3.horizontal.decrease.circle` и т.п.).
/// 
/// ## Нюансы
/// - `Identifiable` через `id: Self` — ок.
/// 


enum SortOption: String, CaseIterable, Identifiable {
    case newestFirst = "Сначала новые"
    case oldestFirst = "Сначала старые"
    case amountDescending = "По убыванию"
    case amountAscending = "По возрастанию"
    
    var id: Self { self }
    
    var iconName: String {
        switch self {
        case .newestFirst:      return "calendar.circle"
        case .oldestFirst:      return "calendar.circle.fill"
        case .amountDescending: return "rublesign.circle"
        case .amountAscending:  return "rublesign.circle.fill"
        }
    }
}
