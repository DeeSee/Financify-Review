# Transaction+ParseCSV.swift — Code Review

## Замечания

### 1. Создание `ISO8601DateFormatter` при каждом вызове (строки 5–8)
Внутри `parse(csvLine:)` на каждый вызов создаётся новый `ISO8601DateFormatter`. Если парсится много строк CSV (в цикле в `TransactionsFileCache.loadFrom(csvFile:)`), это расточительно.

**Рекомендация:** Вынести форматтер наружу (статическое свойство) или передавать как параметр.

### 2. Парсер не обрабатывает quoted fields по стандарту CSV (строки 32–37)
Обработка кавычек в комментарии:
```swift
let comment = columns[5]
    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    .replacingOccurrences(of: "\"\"", with: "\"")
```
Это упрощённый парсинг. Если комментарий содержит разделитель (`,`) внутри кавычек, `split(separator:)` разобьёт его неправильно, и `columns.count == 8` не пройдёт. Стандартный CSV допускает запятые внутри quoted fields.

### 3. Использование `ISO8601DateFormatter` без fractional seconds
Форматтер в CSV-парсере не включает `.withFractionalSeconds`, а форматтер `shmr` — включает. Если даты в CSV содержат миллисекунды, парсинг упадёт.

### 4. `parse(csvLine:)` не используется нигде кроме `TransactionsFileCache`
`TransactionsFileCache` сам практически не используется (содержит закомментированные данные). Весь CSV-парсинг — мёртвый код.
