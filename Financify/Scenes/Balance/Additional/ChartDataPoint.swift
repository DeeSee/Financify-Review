/// ## Ревью: `Financify/Scenes/Balance/Additional/ChartDataPoint.swift`
/// 
/// ## Важно
/// - `id = UUID()` создаётся при каждом создании `ChartDataPoint`.
///   - При пересчёте `chartData` SwiftUI будет считать элементы “новыми”, что может ухудшать анимации/переиспользование.
///   - Более стабильный id — например, `date` (если уникален в массиве).
/// 
/// ## Нюансы
/// - `type` вычисляется как `amount >= 0 ? .income : .expense` — ок.
/// 

import Foundation

struct ChartDataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let amount: Decimal
    
    var type: BalanceChangeType {
        amount >= 0 ? .income : .expense
    }
    
    enum BalanceChangeType: String {
        case income = "Доход"
        case expense = "Расход"
    }
}

enum ChartPeriod: String, CaseIterable, Identifiable {
    case days = "По дням"
    case months = "По месяцам"
    
    var id: String { self.rawValue }
}
