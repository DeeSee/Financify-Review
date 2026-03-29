# CategoriesViewModel.swift — Code Review

## Замечания

### 1. Fuzzy search — производительность O(n * m * k) (строки 93–150)
Алгоритм Дамерау-Левенштейна имеет сложность O(n*m) для одной пары строк. `fuzzyMatch` вызывает его в двойном цикле: для каждой начальной позиции и каждого размера окна. Итого для одного вызова `fuzzyMatch`: O(textLen * threshold * patLen * patLen).

`filteredCategories` вызывает `fuzzyMatch` для каждой категории при каждом изменении `searchText`. Если категорий сотни и текст длинный, это может быть заметно.

**Рекомендация:** Для маленьких списков (десятки категорий) это приемлемо. Но стоит добавить debounce на `searchText` для предотвращения пересчёта при каждом символе.

### 2. `filteredCategories` и `suggestions` — двойной пересчёт
```swift
var filteredCategories: [Category] {
    ...categories.filter { $0.name.fuzzyMatch(searchText) }
}
var suggestions: [String] {
    ...categories.map(\.name).filter { $0.fuzzyMatch(searchText) }
}
```
Оба computed property выполняют fuzzy matching при каждом обращении. SwiftUI может обращаться к ним многократно за один render cycle. Стоит кэшировать результат.

### 3. `threshold` в `fuzzyMatch` — слишком мягкий (строка 132)
```swift
let threshold = max(1, Int(Double(maxLen) * 0.1))
```
10% от длины — для коротких слов (3–5 символов) порог = 1. Это значит, что «Еда» match'ится с «Ела», «Еды», «Ода» и т.д. Возможно, для UX это нормально, но стоит протестировать.

### 4. Дублирование `listenForNetworkStatusChanges`
Паттерн `networkStatusTask = Task { for await ... }` повторяется в **каждом** ViewModel (BalanceViewModel, HistoryViewModel, TransactionsListViewModel, CategoriesViewModel, TransactionEditorViewModel, AnalysisInteractor). Это 6 копий одного и того же кода.

**Рекомендация:** Вынести в base class или протокольное расширение.

### 5. Дублирование обработки ошибок
Блоки `catch NetworkError.serverError { ... } catch NetworkError.encodingFailed { ... }` повторяются в `fetchCategories()`, `HistoryViewModel.refresh()`, `TransactionEditorViewModel.save()` и т.д. Стоит вынести в helper-функцию.
