/// ## Ревью: `Financify/Scenes/Analysis/AnalysisProtocols.swift`
/// 
/// ## Важно
/// - `AnalysisBusinessStorage` содержит много UI‑ориентированных полей (`isLoading`, `selectedSortOption`, `fromDate/toDate`). Для Clean Swift это типично, но стоит понимать: граница между “бизнес‑состоянием” и “UI‑состоянием” размыта.
/// 
/// ## Нюансы
/// - `AnalysisBusinessLogic.makeEditorView(...) -> TransactionEditorView` возвращает SwiftUI View прямо из interactor’а. Это удобная интеграция, но увеличивает связность VIP‑модуля с SwiftUI.
/// 
/// ## Предложения
/// - Если нужно более строгая архитектура: возвращать не View, а данные/роутинг‑команду, а создание SwiftUI‑экрана оставить на уровне сборки/роутера.
/// 

import Foundation
import PieChart

protocol AnalysisBusinessStorage {
    var total: Decimal { get }
    var isLoading: Bool { get } 
    var transactions: [Transaction] { get }
    var direction: Direction { get }
    var summaries: [CategorySummary] { get }
    var currency: Currency { get }
    var fromDate: Date { get }
    var toDate: Date { get }
    var selectedSortOption: SortOption { get }
}

protocol AnalysisBusinessLogic {
    func refresh() async
    func setFromDate(_ date: Date) async
    func setToDate(_ date: Date) async
    func setSortOption(_ option: SortOption) async
    func setShowEmptyCategories(_ flag: Bool) async
    func makeEditorView(for transaction: Transaction?) -> TransactionEditorView
}

protocol AnalysisPresentationLogic {
    func presentCategories(
        summaries: [CategorySummary],
        total: Decimal,
        currency: Currency
    ) async
    
    func presentTransactions(
        transactions: [Transaction],
        total: Decimal,
        currency: Currency,
        categories: [Int: Category]
    ) async
    
    func presentChart(summaries: [CategorySummary]) async
    
    func presentSortOptionChanged() async
    
    func presentDateControlsRefreshed() async
    
    func presentLoading(
        isLoading: Bool
    ) async
    
    
    func presentOfflineStatus(
        isOffline: Bool
    ) async
}
