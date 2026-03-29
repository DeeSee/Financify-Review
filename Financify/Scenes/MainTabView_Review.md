# MainTabView.swift — Code Review

## Замечания

### 1. Настройка UITabBar в `init()` SwiftUI View (строки 8–18)
```swift
init() {
    let tabAppearance = UITabBarAppearance()
    ...
    UITabBar.appearance().standardAppearance = tabAppearance
```
Изменение `UITabBar.appearance()` в `init` SwiftUI View — антипаттерн:
- `init()` может вызываться многократно при пересоздании View.
- `appearance()` — глобальная настройка, которая повлияет на **все** tab bar'ы в приложении.
- Изменять appearance после отображения UI может не иметь эффекта.

**Рекомендация:** Вынести в `FinancifyApp.init()` или в `UIApplicationDelegate`.

### 2. `#available(iOS 15.0, *)` — лишняя проверка (строка 16)
Минимальная версия приложения — iOS 15 (из Package.swift и README). Проверка `#available(iOS 15.0, *)` всегда `true`.

### 3. Вкладка «Настройки» — заглушка (строка 74)
```swift
Text("Настройки")
```
Вкладка настроек — просто текст. Если это WIP — стоит пометить. Если так и задумано — стоит убрать вкладку.

### 4. Прокидывание зависимостей через конструкторы View
Каждый View получает 3–5 сервисов через init. Это создаёт «водопад» зависимостей: `MainTabView` → `TransactionsListView` → `HistoryView` → `TransactionEditorView`. Каждый уровень передаёт одни и те же сервисы.

**Рекомендация:** Использовать `@EnvironmentObject` для сервисов (как уже сделано для `AppDependencies`), но обращаться к нему напрямую в каждом View.

### 5. Форматирование — фигурная скобка `}` на одной строке с `.tabItem` (строки 33, 47, 60, 71, 79)
Закрывающая скобка `.tabItem { ... }` стоит на одной строке с содержимым блока, что ухудшает читаемость.
