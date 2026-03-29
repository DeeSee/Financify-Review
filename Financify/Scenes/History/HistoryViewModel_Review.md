# HistoryViewModel.swift — Code Review

## Баги

### 1. `fromDate` / `toDate` — двойной refresh при взаимной коррекции (строки 18–38)
```swift
@Published var fromDate: Date {
    willSet { if newValue > toDate { toDate = newValue } }
    didSet { Task { await refresh() } }
}
@Published var toDate: Date {
    willSet { if newValue < fromDate { fromDate = newValue } }
    didSet { Task { await refresh() } }
}
```
Сценарий: пользователь ставит `fromDate` в будущее (больше текущего `toDate`):
1. `fromDate.willSet` → `toDate = newValue` → запускает `toDate.didSet` → `refresh()`.
2. `fromDate.didSet` → `refresh()`.

Итого **два параллельных `refresh()`**, один из которых может использовать частично обновлённые даты.

**Рекомендация:** Вынести логику в отдельный метод `setDateRange(from:to:)` с одним вызовом `refresh()`.

### 2. `endOfDay` — `second: -1` (строка 59)
```swift
return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start)!
```
Это даёт `23:59:59.000`. Транзакции с `transactionDate` в интервале `23:59:59.001 ... 23:59:59.999` **не попадут** в фильтр.

**Рекомендация:** Использовать полуоткрытый интервал `[startOfDay, startOfNextDay)`.

## Замечания

### 3. Сервисы экспонируются как `let` (строки 7–9)
```swift
let categoriesService: CategoriesServiceLogic
let transactionsService: TransactionsServiceLogic
let bankAccountService: BankAccountServiceLogic
let reachability: NetworkReachabilityLogic
```
Все сервисы — публичные свойства ViewModel'а. Они доступны из View'ов для передачи в дочерние экраны (`HistoryView` → `AnalysisViewControllerWrapper`, `TransactionEditorView`).

Это нарушает инкапсуляцию ViewModel'а. View не должен знать о зависимостях ViewModel'а.

**Рекомендация:** Создавать дочерние View/ViewModel через фабричные методы ViewModel'а, а не прокидывать сервисы напрямую.

### 4. `self.transactions = []` в начале `refresh()` (строка 93)
Сброс транзакций в пустой массив при каждом refresh вызывает мерцание UI (список пуст → загрузка → список заполнен).
