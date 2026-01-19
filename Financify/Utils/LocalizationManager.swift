/// ## Ревью: `Financify/Utils/LocalizationManager.swift`
/// 
/// ## Критично
/// - **Два force unwrap подряд** при создании bundle:
///   - `Bundle.main.path(forResource:..., ofType:"lproj")!` и затем `Bundle(path: ...)!`.
///   - Если папки локализаций нет или она названа иначе — приложение упадёт.
/// 
/// ## Важно
/// - **Язык выбирается один раз в `init()`** и дальше не обновляется. При смене языка в настройках iOS во время жизни приложения поведение может быть неожиданным.
/// - При наличии `Localizable.xcstrings` можно полагаться на системный механизм локализации, а не поддерживать кастомный менеджер.
/// 
/// ## Предложения
/// - Убрать force unwrap: fallback на `Bundle.main` при отсутствии нужного bundle.
/// - Рассмотреть отказ от `LocalizationManager` в пользу `String(localized:)` / `LocalizedStringKey`.
/// 

import Foundation

final class LocalizationManager {
    // MARK: - Constants
    static let shared = LocalizationManager()
    
    private let bundle: Bundle

    // MARK: - Lifecycle
    private init() {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        
        if preferredLanguage.starts(with: "ru") {
            bundle = Bundle(path: Bundle.main.path(forResource: "ru", ofType: "lproj")!)!
        } else {
            bundle = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj")!)!
        }
    }

    // MARK: - Methods
    final func localizedString(forKey key: String) -> String {
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
