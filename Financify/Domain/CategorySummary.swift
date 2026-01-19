/// ## Ревью: `Financify/Domain/CategorySummary.swift`
/// 
/// ## Нюансы
/// - `percent` хранится как mutable поле с дефолтом `0`, но по текущему коду процент вычисляется в Presenter (и в UI передаётся строкой).
/// - Поле `percent` **нигде не используется** в проекте; фактический процент считается локальной переменной в `AnalysisPresenter`.
/// 
/// ## Предложения
/// - Либо сделать `percent` вычисляемым (при наличии `totalAll`), либо удалить и оставить только `total`.
/// 

import Foundation

/// Cколько потрачено в категории за период
struct CategorySummary {
    let category: Category
    let total: Decimal
    var percent: Double = 0
}
