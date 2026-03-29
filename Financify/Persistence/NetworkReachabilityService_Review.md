# NetworkReachabilityService.swift + NetworkReachabilityLogic.swift + NetworkStatus.swift — Code Review

## Баги

### 1. `NetworkReachabilityService` не является `Sendable`, но протокол требует (NetworkReachabilityLogic.swift, строка 3)
```swift
protocol NetworkReachabilityLogic: Sendable {
```
`NetworkReachabilityService` — обычный `final class` с мутабельным состоянием (`currentStatus`, `continuation`). Он не `actor`, не `@Sendable`, не защищён синхронизацией. При этом:
- `currentStatus` мутируется из GCD-очереди `queue` (в `pathUpdateHandler`).
- `currentStatus` читается из разных потоков/акторов (через `reachability.currentStatus`).

Это **гонка данных (data race)** в Swift 6 strict concurrency.

**Рекомендация:** Сделать `NetworkReachabilityService` актором, или использовать `@unchecked Sendable` с ручной синхронизацией, или защитить `currentStatus` через lock.

### 2. `continuation` может быть перезаписан (строки 10, 22)
`statusStream` — lazy property, при обращении к которому `continuation` сохраняется в свойство. Но если `statusStream` запросить повторно (или из двух мест одновременно), `AsyncStream` уже создан (lazy), но если `continuation` будет перезаписан — первый подписчик перестанет получать обновления.

На практике `statusStream` lazy — значит создаётся один раз. Но `continuation` хранится отдельно, что хрупко.

### 3. `print()` в продакшен-коде (строки 46, 49)
Сообщения `"Network connection [ONLINE]"` / `"[OFFLINE]"` выводятся через `print`. В продакшене это не нужно — стоит использовать `os_log` или убрать.

### 4. Проверка только wifi/cellular (строка 45)
```swift
if path.status == .satisfied && (path.usesInterfaceType(.wifi) || path.usesInterfaceType(.cellular))
```
Ethernet (при подключении к Mac) и другие интерфейсы игнорируются. Также `.wiredEthernet` актуален для iPad с USB-C хабом.
