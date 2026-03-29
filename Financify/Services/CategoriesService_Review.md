# CategoriesService.swift — Code Review

## Замечания

### 1. `client` — не `private` (строка 12)
```swift
let client: NetworkClient
```
В отличие от `BankAccountService` и `TransactionsService`, где `client` помечен `private`, здесь он доступен извне. Нарушение инкапсуляции.

### 2. `updateLocalStore` — удаление всех + вставка заново (строки 50–58)
```swift
try modelContext.delete(model: PersistentCategory.self)
try modelContext.save()
for category in categories {
    modelContext.insert(PersistentCategory(from: category))
}
try modelContext.save()
```
Стратегия "удалить всё, вставить заново":
- Двойной `save()` — неэффективно. Достаточно одного в конце.
- Между `delete` + `save` и `insert` + `save` есть окно, когда в базе нет категорий. Если параллельный запрос прочитает категории в этот момент, получит пустой список.
- Лучше использовать upsert (найти по id, обновить или вставить).

### 3. `getCategories(by direction:)` — лишний сетевой запрос
```swift
func getCategories(by direction: Direction) async throws -> [Category] {
    let allCategories = try await getAllCategories()
    return allCategories.filter { $0.direction == direction }
}
```
Каждый вызов `getCategories(by:)` заново загружает **все** категории с сервера, а потом фильтрует локально. Есть `categoriesTypeGET(isIncome:)` endpoint, который мог бы загрузить только нужные.

Или можно кэшировать результат `getAllCategories` и фильтровать из кеша.
