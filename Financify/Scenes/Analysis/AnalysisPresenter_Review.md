# AnalysisPresenter.swift — Code Review

## Замечания

### 1. `DispatchQueue.main.async` вместо `@MainActor` (строки 11–13)
```swift
func presentOfflineStatus(isOffline: Bool) async {
    DispatchQueue.main.async { [weak view] in
        view?.displayOfflineStatus(isOffline: isOffline)
    }
}
```
В async-функции, помеченной `@MainActor` (класс помечен), использование `DispatchQueue.main.async` — это переход в unstructured concurrency. Кроме того, `displayOfflineStatus` и `displayLoading` вызываются через GCD, а `applyCategories`, `applyTransactions`, `applyChart` — через `await MainActor.run`.

**Рекомендация:** Использовать единообразный подход. Раз класс `@MainActor`, можно вызывать методы View напрямую.

### 2. `presentLoading` — не через `await` (строка 93)
```swift
func presentLoading(isLoading: Bool) async {
    view?.displayLoading(isLoading: isLoading)
}
```
Здесь метод вызывается синхронно (без `await MainActor.run`), в отличие от `presentOfflineStatus`. Непоследовательность.

### 3. Presenter не форматирует данные полностью
В VIP Presenter отвечает за преобразование данных из «бизнес-формата» в «формат для отображения». Но:
- `presentCategories` делает вычисления (процент = amount/total * 100) — это бизнес-логика, не форматирование.
- Форматирование суммы (`moneyFormatted`) делается и в Presenter'е, и в View (через TransactionCell).

Границы ответственности размыты.
