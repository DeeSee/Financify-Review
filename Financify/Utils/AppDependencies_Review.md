# AppDependencies.swift — Code Review

## Замечания

### 1. Нет протоколов — невозможно тестировать
`AppDependencies` создаёт конкретные реализации всех сервисов. Нет способа подставить мок для тестирования UI или ViewModel'ов.

**Рекомендация:** Либо внедрять зависимости через протоколы, либо создать `AppDependenciesProtocol`.

### 2. `@MainActor` + `ObservableObject` (строка 4)
`AppDependencies` — `@MainActor`, но он содержит actor-сервисы (`BankAccountService`, `TransactionsService` и т.д.). Это правильно (акторы можно хранить где угодно), но вызовы к ним всё равно потребуют `await`.

### 3. Все сервисы создают свой `NetworkClient()`
Каждый сервис (через default parameter) создаёт **свой экземпляр** `NetworkClient`. Это значит три разных `Alamofire.Session.default`. Можно шарить один `NetworkClient`.
