# TransactionsListViewModel.swift — Code Review

## Замечания

### 1. `endOfDay` — та же проблема с `-1 секунда` (строка 82)
```swift
let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
```
Аналогично `HistoryViewModel` — потенциально пропускает транзакции в последнюю секунду дня.

### 2. `self.transactions = []` — мерцание UI (строка 59)
Как и в `HistoryViewModel`, сброс данных перед загрузкой вызывает пустой экран во время рефреша.

### 3. `selectedSortOption.didSet` (строки 19–23)
```swift
@Published var selectedSortOption: SortOption = .newestFirst {
    didSet { Task { await refresh() } }
}
```
Изменение сортировки вызывает полный `refresh()` (сетевой запрос!). Для пересортировки достаточно локально отсортировать уже загруженные данные.

### 4. Дублирование с `HistoryViewModel`
`TransactionsListViewModel` и `HistoryViewModel` практически идентичны: тот же набор сервисов, та же логика `refresh()`, та же сортировка, те же `listenForNetworkStatusChanges`. Отличия: период фильтрации (сегодня vs произвольный) и несколько UI-флагов.

**Рекомендация:** Вынести общую логику в базовый класс или compose-модуль.
