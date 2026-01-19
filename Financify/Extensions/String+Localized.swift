/// ## Ревью: `Financify/Extensions/String+Localized.swift`
/// 
/// ## Важно
/// - **Глобальное расширение `String.localized`** удобно, но:
///   - оно скрывает источник строк и затрудняет статический анализ (какие ключи реально используются).
///   - при переходе на `Localizable.xcstrings` + системные механизмы может оказаться лишним.
/// 
/// ## Предложения
/// - Рассмотреть `String(localized:)` / `LocalizedStringKey` в SwiftUI и отказаться от кастомного менеджера.
/// - Если оставить — добавить fallback на ключ, логирование отсутствующих ключей и убрать force unwrap в `LocalizationManager`.
/// 

import UIKit

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(forKey: self)
    }
}
