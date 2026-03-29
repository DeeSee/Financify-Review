# ChartDataPoint.swift — Code Review

## Баги

### 1. `Equatable` с `UUID` (строка 4)
```swift
struct ChartDataPoint: Identifiable, Equatable {
    let id = UUID()
```
`Equatable` синтезирован автоматически, что включает `id: UUID`. Два `ChartDataPoint` с одинаковыми `date` и `amount` **никогда не будут равны**, потому что у них разные UUID.

Это влияет на `.animation(.value:)` в `BalanceView` (строка 229):
```swift
.animation(.easeInOut(duration: 0.2), value: viewModel.chartData)
```
При каждом `refreshBalance()` создаются новые `ChartDataPoint` с новыми UUID → массив всегда «изменился» → анимация всегда срабатывает, даже если данные не поменялись.

**Рекомендация:** Реализовать кастомный `==`, сравнивающий только `date` и `amount`. Или сделать `id` детерминированным (например, из date).

## Замечания

### 2. `rawValue` для `BalanceChangeType` — русские строки
```swift
case income = "Доход"
case expense = "Расход"
```
Используется в `chartForegroundStyleScale` как ключ для маппинга цветов. Если локализовать — сломается маппинг.
