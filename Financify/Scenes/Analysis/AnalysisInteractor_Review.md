# AnalysisInteractor.swift — Code Review

## Баги

### 1. Отсутствие actor isolation — гонка данных (строки 211–226)
```swift
private func listenForNetworkStatusChanges() {
    networkStatusTask = Task(priority: .userInitiated) {
        for await status in reachability.statusStream {
            let wasOffline = self.isOffline
            await MainActor.run { self.isOffline = status == .offline }
            ...
            await self.refresh()
        }
    }
}
```
`AnalysisInteractor` — обычный `final class`, **не actor**. Метод `listenForNetworkStatusChanges` создаёт `Task` (которая выполняется на произвольном executor), и в ней:
- Читает `self.isOffline` (строка 213) — без синхронизации.
- Мутирует `self.isOffline` через `MainActor.run` (строка 216).
- Вызывает `self.refresh()` (строка 221), который мутирует множество свойств.

Параллельно, `refresh()` может быть вызван из `viewWillAppear` (строка 84 в ViewController). Это **гонка данных**.

**Рекомендация:** Сделать `AnalysisInteractor` актором, или защитить все мутации.

### 2. `AnalysisModels.swift` — пустой файл
```swift
enum AnalysisModels { }
```
Мёртвый код. В VIP-архитектуре Models содержит Request/Response structs. Здесь — пусто.

## Архитектурные замечания

### 3. VIP нарушен — Interactor берёт на себя роль Model
`AnalysisInteractor` хранит состояние (`transactions`, `categories`, `summaries`, `isLoading`, `currency`, `fromDate`, `toDate`, `selectedSortOption`) — это ответственность Model в VIP, а не Interactor. Interactor должен координировать бизнес-логику, а не быть хранилищем.

### 4. `AnalysisBusinessStorage` — нарушение принципа единой ответственности
Протокол `AnalysisBusinessStorage` предоставляет read-only доступ к данным Interactor'а:
```swift
protocol AnalysisBusinessStorage {
    var total: Decimal { get }
    var transactions: [Transaction] { get }
    ...
}
```
ViewController напрямую читает данные из Interactor'а через этот протокол. Это нарушает VIP: View не должен читать данные из Interactor'а напрямую — данные должны проходить через Presenter.

### 5. `makeEditorView(for:)` — Interactor создаёт SwiftUI View (строки 229–241)
```swift
func makeEditorView(for transaction: Transaction?) -> TransactionEditorView { ... }
```
Interactor создаёт View — это грубое нарушение архитектуры. Interactor не должен знать о View-слое.

### 6. Дублирование `reapplyFiltersAndSort` с ViewModel'ами
Логика фильтрации и сортировки транзакций дублируется между `AnalysisInteractor`, `HistoryViewModel`, `TransactionsListViewModel`.
