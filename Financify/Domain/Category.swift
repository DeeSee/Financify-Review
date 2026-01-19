/// ## Ревью: `Financify/Domain/Category.swift`
/// 
/// ## Важно
/// - Модель хранит `emoji` как `Character`, а в JSON ожидается `String`. Это ок.
/// - Проверка `emojiString.count == 1` обычно работает корректно для emoji (Swift считает extended grapheme cluster), но если в API внезапно придёт пустая строка — будет decoding error (что, скорее, хорошо).
/// 
/// ## Нюансы
/// - `direction` строится через `isIncome ? .income : .outcome` — это связывает модель с текущим неймингом `Direction` (см. `Direction_Review.md`).
/// 
/// ## Предложения
/// - Для расширяемости (добавление новых типов категорий/направлений) лучше использовать отдельный enum на доменном уровне вместо `Bool`.
/// 

import Foundation

struct Category: Codable, Identifiable {
    let id: Int
    var name: String
    var emoji: Character
    var isIncome: Bool
    
    var direction: Direction {
        isIncome ? .income : .outcome
    }
    
    init(
        id: Int,
        name: String,
        emoji: Character,
        isIncome: Bool
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }
    
    // Для Codable
    private enum CodingKeys: String, CodingKey {
        case id, name, emoji, isIncome
    }
    
    // Десериализация
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self,   forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isIncome = try container.decode(Bool.self,   forKey: .isIncome)

        let emojiString = try container.decode(String.self, forKey: .emoji)
        guard let first = emojiString.first, emojiString.count == 1 else {
            throw DecodingError.dataCorruptedError(
                forKey: .emoji,
                in: container,
                debugDescription: "Строка emoji может быть исключительно длины 1"
            )
        }
        emoji = first
    }
    
    // Сериализация
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id,       forKey: .id)
        try container.encode(name,     forKey: .name)
        try container.encode(isIncome, forKey: .isIncome)
        try container.encode(String(emoji), forKey: .emoji)
    }
}
