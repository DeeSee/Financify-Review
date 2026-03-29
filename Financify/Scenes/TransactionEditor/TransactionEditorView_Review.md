# TransactionEditorView.swift + TransactionEditorViewModel.swift — Code Review

## Баги

### 1. `deleteTransaction()` → `dismiss()` без проверки ошибки (строки 46–49 в View)
```swift
Button(role: .destructive) {
    Task {
        await viewModel.deleteTransaction()
        dismiss()
    }
}
```
`dismiss()` вызывается **всегда**, даже если удаление не удалось (ViewModel покажет alert, но экран уже закроется). Пользователь не увидит сообщение об ошибке.

**Рекомендация:** Проверять `viewModel.showAlert` перед `dismiss()`.

### 2. `timePickerRow` — `range` вычисляется, но не всегда применяется (строки 157–168)
```swift
let range: PartialRangeThrough<Date>? = isToday ? ...now : nil
```
Если `range == nil`, `CustomDatePickerStyle` создаётся без ограничения, и пользователь может выбрать любое время. Но для прошлых дат это неограниченно — пользователь может поставить, например, 25:00 (если DatePicker позволит). На практике UIDatePicker ограничивает до 23:59, так что это скорее conceptual issue.

### 3. `sanitizeAmount` — неполная валидация (ViewModel, строки 94–113)
- Не ограничивает количество цифр после десятичного разделителя (пользователь может ввести `123,456789`).
- Не ограничивает общую длину числа.
- Ведущий ноль убирается только если следующий символ — цифра, но не если следующий — разделитель (`0,5` останется как есть — это ок).

### 4. `editingTransaction!.id` — force-unwrap (ViewModel, строка 150)
```swift
try await transactionsService.updateTransaction(transactionRequest, with: editingTransaction!.id)
```
Если `isNew == false`, `editingTransaction` должен быть non-nil, но force-unwrap — хрупкое решение.

## Замечания

### 5. Дублирование обработки ошибок
Блоки `catch NetworkError.serverError { ... }` повторяются в `save()` (строки 152–180) и `deleteTransaction()` (строки 187–215) — идентичный код, отличается только `alertMessage`.

### 6. `Constants.DeleteSection.deleteButtonTitle = "Удалить расход"` (строка 199)
Текст кнопки всегда «Удалить расход», даже для доходов. Должен быть «Удалить доход» в соответствующем контексте.
