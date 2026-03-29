# AnalysisViewController.swift — Code Review

## Замечания

### 1. `Section(rawValue: section)!` — force-unwrap (строки 337, 353, 371, 407)
Если `numberOfSections` вернёт значение, не покрытое enum'ом `Section`, приложение упадёт. Хотя UITableView не должен запросить section за пределами `numberOfSections`, force-unwrap — плохая практика.

### 2. `ControlRow(rawValue: indexPath.row)!` — аналогично (строка 374)

### 3. `makeSortCell` — переиспользование ячейки без очистки (строки 438–483)
```swift
cell.contentView.subviews.forEach { $0.removeFromSuperview() }
cell.textLabel?.text = Constants.CellTitle.sort
```
Ячейка очищается вручную, но `textLabel` (который принадлежит contentView в UITableViewCell style `.default`) не удаляется. Потенциальные проблемы при переиспользовании.

### 4. `offlineBannerVC` — ручное управление child VC (строки 240–283)
Весь код добавления/удаления banner'а — ручное управление child view controller с анимациями. В UIKit-части проекта (AnalysisViewController) это делается вручную, а в SwiftUI-части — через `.overlay`. Два разных подхода для одного и того же элемента.

### 5. `didSelectRowAt` — доступ к `interactor.transactions[indexPath.row]` (строка 408)
```swift
let tx = interactor.transactions[indexPath.row]
```
Если `interactor.transactions` обновится между `numberOfRowsInSection` и `didSelectRowAt` (например, из-за фонового обновления), индекс может быть out of bounds. Нет проверки.

### 6. `presentEditor` — модальный UIHostingController (строки 229–238)
ViewController создаёт SwiftUI View через `interactor.makeEditorView(for:)`. Это работает, но:
- При dismiss модального контроллера `presentationControllerDidDismiss` вызывает `refresh()`, а `onDismiss` в `fullScreenCover` — нет. `UIHostingController` с `modalPresentationStyle = .fullScreen` не вызывает `presentationControllerDidDismiss` (это метод для `.pageSheet`/`.formSheet`).

**Рекомендация:** Для `.fullScreen` использовать `viewWillAppear` вместо `presentationControllerDidDismiss`.
