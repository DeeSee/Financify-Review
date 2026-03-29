# Category.swift — Code Review

## Замечания

### 1. `emoji` как `Character` — проблема с Codable
Использование `Character` для emoji усложняет кодирование/декодирование (кастомные `init(from:)` и `encode(to:)` нужны только из-за этого). Стоит рассмотреть `String` с валидацией длины.

### 2. Валидация emoji при декодировании (строки 38–45)
```swift
guard let first = emojiString.first, emojiString.count == 1 else {
```
Условие `emojiString.count == 1` некорректно для составных emoji (например, 👨‍👩‍👧‍👦 — это один символ в Swift, но некоторые emoji состоят из нескольких Unicode scalar). Впрочем, `String.count` в Swift считает именно grapheme clusters, так что для обычных emoji это работает. Просто стоит иметь в виду.

### 3. `direction` — computed property в модели
`var direction: Direction` вычисляется на лету из `isIncome`. Это удобно, но создаёт семантическое дублирование: `isIncome` и `direction` выражают одно и то же. Стоит определиться с одним источником правды.
