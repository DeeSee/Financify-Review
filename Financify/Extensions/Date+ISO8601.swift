/// ## Ревью: `Financify/Extensions/Date+ISO8601.swift`
/// 
/// ## Важно
/// - **Нормализация ISO8601 работает только для строк, оканчивающихся на `Z`**:
///   - При ответах со временем с оффсетом (`+00:00`) без fractional seconds `normalizedISO8601` его не поправит, а `ISO8601DateFormatter` с `.withFractionalSeconds` может не распарсить.
/// - `ISO8601DateFormatter.shmr` настроен на `.withFractionalSeconds`, но данные “в природе” часто приходят и без дробных секунд.
/// 
/// ## Предложения
/// - Парсить через “fallback chain”: сначала `.withFractionalSeconds`, затем без дробных секунд.
/// - Явно закрепить ожидаемый формат API (контракт) и под него настроить decoder.
/// 

import Foundation

fileprivate extension String {
    var normalizedISO8601: String {
        guard hasSuffix("Z") else { return self }
        return contains(".")
            ? self
            : replacingOccurrences(of: "Z", with: ".000Z")
    }
}

extension ISO8601DateFormatter {
    static let shmr: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fmt
    }()

    func dateNormalized(from string: String) -> Date? {
        return date(from: string.normalizedISO8601)
    }
}
