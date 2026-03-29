# PersistentCategory.swift — Code Review

## Баги

### 1. Force-unwrap в `emoji` getter (строка 15)
```swift
var emoji: Character {
    get { return emojiString.first! }
```
Если `emojiString` окажется пустой строкой (например, из-за повреждения данных в SwiftData, миграции, или бага при записи), приложение упадёт с `fatalError`.

**Рекомендация:** Использовать безопасный unwrap с fallback:
```swift
get { return emojiString.first ?? "❓" }
```

### 2. `@Transient` и SwiftData
`emoji` помечен `@Transient`, что значит он не сохраняется в базу. Это правильно — в базу сохраняется `emojiString`. Но если кто-то попробует сделать предикат по `emoji` в `FetchDescriptor`, это не сработает.
