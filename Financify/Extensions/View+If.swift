/// ## Ревью: `Financify/Extensions/View+If.swift`
/// 
/// ## Что хорошо
/// - Удобный helper для условного применения модификаторов без дублирования кода.
/// 
/// ## Нюансы
/// - Использование имени метода ``if`` (через backticks) — распространённый приём, но иногда ухудшает читаемость в больших view‑деревьях.
/// 
/// ## Предложения
/// - Если проект вырастет, можно рассмотреть более явное имя (`applyIf`, `modifyIf`) для повышения читаемости.
/// 

import SwiftUI

extension View {
    /// Применяет `transform`, если `condition == true`, иначе возвращает self.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
