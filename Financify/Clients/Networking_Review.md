# Networking.swift — Code Review

## Баги

### 1. `AFError.underlyingData` всегда возвращает `nil` (строки 276–284)
Расширение `AFError` предположительно должно извлекать тело ответа из ошибки, но во всех ветках возвращает `nil`. В результате `NetworkError.serverError(statusCode:, data:)` всегда получает `data: nil`, и отладка серверных ошибок невозможна — тело ответа теряется.

**Рекомендация:** Реализовать реальное извлечение данных из `AFError`, или передавать данные иным путём (например, через `response.data` у `DataRequest`).

### 2. `encode`/`decode` через `DispatchQueue` + `withCheckedThrowingContinuation` (строки 230–254)
JSON-кодирование/декодирование маленьких DTO — операция на микросекунды. Оборачивание в `DispatchQueue.global` + continuation создаёт ненужный overhead (переключение потока, аллокация continuation) и усложняет стек-трейсы. Кроме того, это не cooperative concurrency — structured concurrency не может отменить работу на GCD-очереди.

**Рекомендация:** Кодировать/декодировать синхронно прямо в async-методе. Если нужна отмена — использовать `Task.detached` или `Task { }`.

## Архитектурные замечания

### 3. `APIEndpoint.baseURL` — захардкоженный URL (строка 6)
Продакшен-URL зашит прямо в enum. Нет возможности использовать staging/dev сервер, нет удобного способа мокать для тестов.

**Рекомендация:** Вынести `baseURL` в конфигурацию (xcconfig / environment / inject через init).

### 4. HTTP-метод определяется на стороне вызывающего кода
`APIEndpoint` кодирует только путь, но не метод. Вызывающий код должен вручную сопоставлять `accountsPOST` с `.post`, `accountsGETby` с `.get` и т.д. Это хрупко — ничто не мешает вызвать `accountsGET` с методом `.delete`.

**Рекомендация:** Сделать HTTP-метод частью `APIEndpoint` (добавить `var method: HTTPMethod`).

### 5. `NetworkClient` — финальный класс без протокола
Нет протокола для `NetworkClient`, что делает невозможным подмену для тестирования. Все сервисы зависят от конкретного класса.

**Рекомендация:** Выделить протокол (например, `NetworkClientProtocol`) и внедрять его через DI.

### 6. `categoriesTypeGET` формирует путь с `Bool` (строка 30)
`"/categories/type/\(isIncome)"` — путь будет `/categories/type/true` или `/categories/type/false`. Если API ожидает другой формат (напр. `income`/`expense`), это будет ошибкой. Стоит проверить контракт API.

## Стиль / Мелочи

### 7. Дублирование логики обработки ошибок
Блоки `catch let afError as AFError { ... }` дублируются в `request` (строки 107–118) и `requestStatus` (строки 183–191, 219–226). Стоит вынести в приватный метод.

### 8. Trailing comma (строка 141)
```swift
func requestStatus(
    _ endpoint: APIEndpoint,
    method: HTTPMethod,   // <-- trailing comma
) async throws -> Int {
```
Trailing comma в списке параметров — допустимо начиная со Swift 5.9, но выглядит неконсистентно с остальными методами.
