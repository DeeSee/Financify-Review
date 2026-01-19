/// ## Ревью: `Financify/Extensions/Transaction+JsonObject.swift`
/// 
/// ## Важно
/// - При ошибке кодирования/сериализации метод возвращает **пустой словарь** (`[:]`) без сигнала об ошибке. Это может скрывать проблемы данных и приводить к “тихим” сбоям.
/// - Этот код используется в тестах и потенциально в импорте/экспорте: “пустой JSON” — плохой failure mode.
/// 
/// ## Предложения
/// - Изменить контракт на `throws` или `Result`.
/// - Как минимум в debug‑сборке логировать причину.
/// 

import Foundation

extension Transaction {
    var jsonObject: Any {
        guard let data = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(
                with: data,
                options: []
              ) else {
            return [:] as [String: Any]
        }
        
        return json
    }
}
