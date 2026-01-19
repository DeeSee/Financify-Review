## Внутренние заметки по проекту (для ревьюера)

## Карта слоёв
- **UI (SwiftUI)**: экраны `TransactionsList`, `History`, `Balance`, `Categories`, `TransactionEditor`.
- **UI (UIKit/VIP)**: модуль `Analysis` (`AnalysisViewController` + Interactor/Presenter).
- **Services (Actor)**: `BankAccountService`, `TransactionsService`, `CategoriesService`.
- **Persistence (SwiftData)**:
  - Основные локальные модели: `PersistentTransaction`, `PersistentCategory`, `PersistentBankAccount`.
  - Очередь офлайн-операций: `PendingOperation` через `BackupService`.
  - Синхронизация: `SynchronizationService` (actor), реплеит `PendingOperation` в сеть.
- **Networking**: `NetworkClient` (Alamofire), `APIEndpoint`, `NetworkError`.

## Потоки данных (как сейчас)
- **Онлайн**: ViewModel → Service → `NetworkClient` → ответ → (иногда) обновление SwiftData.
- **Офлайн**:
  - Изменения пишутся в SwiftData + в `PendingOperation`.
  - Синхронизация (при online) реплеит операции в API и удаляет успешные/«фатальные» из очереди.
  - UI при падении сети часто делает fallback на SwiftData, иногда “накладывая” pending операции поверх базы.

## Главные архитектурные риски (приоритет)
- **SwiftData & конкурентность**:
  - `BackupService` — не actor, но используется из нескольких акторов/потоков → риск гонок `ModelContext`.
  - `@Model` классы помечены `Sendable` → может маскировать реальные проблемы потокобезопасности.
- **Offline-first семантика**:
  - `TransactionsService.updateLocalStore` удаляет все транзакции и перезаписывает → риск потери/“мерцания” офлайн изменений, которые ещё висят в очереди.
  - `SynchronizationService` реплеит POST/PUT/DELETE, но **не делает reconciliation** (например, temp id для POST).
  - Политика “4xx = фатально удаляем из очереди” опасна для 401/403/429/409 (данные пользователя могут быть потеряны).
- **UI/VM**:
  - `BalanceViewModel.selectedCurrency` триггерит сетевое обновление даже при присваивании из `refreshBalance` → риск лишних PUT и циклов.
  - `HistoryViewModel` может делать двойной `refresh()` из-за связки `willSet/didSet` на датах.

## Что бы я сделал в следующем шаге (если это станет задачей)
- **Сделать `BackupService` actor’ом** или изолировать его `ModelContext` (например, отдельным актором/очередью).
- **Пересмотреть стратегию обновления локального стора**: вместо wipe-and-replace → upsert + “наложение” pending операций.
- **Добавить reconciliation для офлайн POST**: локальный UUID/temporaryId → после успешного POST обновить локальный объект реальным id.
- **Нормализовать обработку ошибок**: единый слой для отображения ошибок в UI, логирование через `Logger`, вытаскивание тела ошибки из Alamofire.

