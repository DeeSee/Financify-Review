/// ## Ревью: `Financify/Persistence/PersistentCategory.swift`
/// 
/// ## Критично
/// - **`@Model final class PersistentCategory: Sendable`**: как и для других SwiftData-моделей, `Sendable` выглядит небезопасно и может скрывать реальные проблемы конкурентности.
/// - **`emojiString.first!`** в геттере `emoji`: если по любой причине `emojiString` станет пустой строкой (миграция/битые данные), это приведёт к крэшу.
/// 
/// ## Важно
/// - **Хранение emoji через “string + computed Character”** — рабочий подход, но:
///   - стоит гарантировать инвариант “строка всегда длины 1” на уровне init/сеттеров + добавить защиту в геттере (без force unwrap).
/// 
/// ## Предложения
/// - Убрать `Sendable`.
/// - Сделать `emoji` более безопасным:
///   - либо хранить `emojiString` как `String` и валидировать,
///   - либо хранить unicode scalar/кодпоинт.
/// 

import Foundation
import SwiftData

@Model
final class PersistentCategory: Sendable {
    @Attribute(.unique)
    var id: Int
    var name: String
    
    private var emojiString: String
    
    @Transient
    var emoji: Character {
        get {
            return emojiString.first!
        }
        set {
            self.emojiString = String(newValue)
        }
    }
    
    var isIncome: Bool
    
    init(id: Int, name: String, emoji: Character, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emojiString = String(emoji)
        self.isIncome = isIncome
    }
    
    convenience init(from domain: Category) {
        self.init(
            id: domain.id,
            name: domain.name,
            emoji: domain.emoji,
            isIncome: domain.isIncome
        )
    }
    
    func toDomain() -> Category {
        Category(
            id: id,
            name: name,
            emoji: emoji,
            isIncome: isIncome
        )
    }
}
