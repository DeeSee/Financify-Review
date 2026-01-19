/// ## Ревью: `Financify/Scenes/TransactionsList/SummaryCell.swift`
/// 
/// ## Нюансы
/// - Используется `moneyFormatted`, который сейчас:
///   - не показывает дробную часть,
///   - и опирается на общий `NumberFormatter` (см. `Decimal+MoneyFormatter_Review.md`).
/// 
/// ## Предложения
/// - Если суммы должны быть с копейками/центами — обновить форматтер и отображение.
/// - Вынести форматирование суммы в единый слой/форматтер, чтобы UI‑компоненты не зависели от деталей реализации.
/// 

import SwiftUI

struct SummaryCell: View {
    // MARK: - Properties
    var total: Decimal
    var title: String
    var currency: Currency
    
    var body: some View {
        HStack {
            Text(verbatim: title)
            Spacer()
            Text("\(total.moneyFormatted) \(currency.rawValue)")
                .foregroundStyle(.secondPrimary)
        }
    }
}
