# BalanceView.swift — Code Review

## Баги

### 1. `commitTotalEdit` — невозможно ввести дробную часть (строки 334–346)
```swift
let digitsAndDot = text.filter { $0.isWholeNumber }
```
`isWholeNumber` пропускает только цифры `0-9`. Десятичный разделитель (`.` или `,`) **отфильтровывается**. В итоге:
- Пользователь вводит `"1234.56"` → `digitsAndDot = "123456"` → баланс = 123 456.
- Нет возможности установить дробный баланс.

**Рекомендация:** Также пропускать `.` или `,` (в зависимости от локали) и использовать `Decimal(string:)` с правильным форматтером.

### 2. `chartSection` — force-unwrap `viewModel.chartDateLabels!` (строка 247)
```swift
let labels = viewModel.chartDateLabels!
```
Хотя `@ViewBuilder` выше проверяет `viewModel.chartDateLabels != nil`, force-unwrap — хрупкое решение. Если условие изменится или будет рефакторинг, приложение крашнется.

**Рекомендация:** Использовать `guard let`.

### 3. `chartSelectionPopover` — мёртвый код (строки 278–298)
Функция `chartSelectionPopover(for:at:)` определена, но **нигде не вызывается**. Вместо неё используется `ChartInteractionOverlay` с собственной логикой отображения. Удалить.

## Замечания

### 4. Дублирование `.if(viewModel.isLoading)` (строки 51–71)
Паттерн:
```swift
.if(viewModel.isLoading) { view in view.redacted(reason: .placeholder) }
.if(!viewModel.isLoading) { view in view.unredacted() }
```
Повторяется 3 раза. Стоит вынести в ViewModifier.

### 5. `selectedCurrency.didSet` вызывает `refreshBalance()` (BalanceViewModel, строки 18–26)
При изменении `selectedCurrency` во ViewModel:
1. Обновляется валюта на сервере (`updatePrimaryCurrency`).
2. Вызывается `refreshBalance()`.
3. `refreshBalance()` получает аккаунт с сервера и устанавливает `selectedCurrency` из ответа.
4. Если ответ содержит старую валюту (сервер ещё не обновился), `didSet` сработает снова.

Потенциальная бесконечная рекурсия. Защита `guard oldValue != selectedCurrency` спасает, но только если сервер вернёт именно ту валюту, что мы только что установили.

### 6. `isEditing ? Color.white : Color.accent` — захардкоженный белый цвет (строка 125)
В dark mode белый фон будет выглядеть плохо. Стоит использовать `Color(.systemBackground)`.

### 7. `TransactionDetailPopupView` — вложенная структура (строки 300–320)
Private view, вложенная в `BalanceView`. Это нормально, но для тестирования/переиспользования лучше вынести в отдельный файл.
