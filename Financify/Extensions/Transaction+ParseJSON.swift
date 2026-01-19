/// ## Ревью: `Financify/Extensions/Transaction+ParseJSON.swift`
/// 
/// ## Важно
/// - Метод возвращает `nil` при любой ошибке (сериализация JSON / декодирование). Это удобно, но сильно усложняет диагностику проблем (потеря контекста ошибки).
/// 
/// ## Предложения
/// - Для production‑кода рассмотреть вариант `throws` (или хотя бы логирование ошибки в debug‑сборке).
/// - Если оставить `nil`‑API — добавить отдельный диагностический метод для тестов/отладки.
/// 

import Foundation

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        guard let data = try? JSONSerialization.data(
            withJSONObject: jsonObject,
            options: []
        ),
              let transaction = try? JSONDecoder().decode(
                Transaction.self,
                from: data
              ) else {
            return nil
        }
        
        return transaction
    }
}
