# BalanceViewModel.swift — Code Review

## Замечания

### 1. `updateChartData()` создаёт неструктурированную Task (строка 109)
```swift
private func updateChartData() {
    Task { ... }
}
```
Неструктурированная `Task` внутри `@MainActor` класса. Если `updateChartData()` вызывается несколько раз быстро (например, при изменении периода), несколько Task будут работать параллельно, и результат последней может быть перезаписан более ранней.

**Рекомендация:** Хранить `Task` в свойстве и отменять предыдущую при новом вызове.

### 2. `listenForNetworkStatusChanges` — вложенная Task (строки 213–227)
```swift
networkStatusTask = Task(priority: .userInitiated) { @MainActor in
    for await status in reachability.statusStream {
        ...
        if wasOffline && !self.isOffline {
            Task { @MainActor [weak self] in
                ...
                await refreshBalance()
            }
        }
    }
}
```
Внутри `Task` создаётся ещё одна `Task`. Внешняя Task уже `@MainActor`, поэтому вложенная `Task { @MainActor [weak self] in` — избыточна.

### 3. `calculateDailyData` / `calculateMonthlyData` — дублирование (строки 119–211)
80% кода в этих двух методах идентичен (загрузка транзакций, группировка, подсчёт). Отличается только период и способ группировки. Стоит вынести общую логику.

### 4. `categories` запрашиваются при каждом `calculateDailyData/calculateMonthlyData`
```swift
let categories = try? await categoriesService.getAllCategories()
```
Каждый пересчёт графика делает сетевой запрос за категориями. Категории меняются редко — стоит кэшировать.
