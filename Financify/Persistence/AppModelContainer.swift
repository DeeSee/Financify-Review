/// ## Ревью: `Financify/Persistence/AppModelContainer.swift`
/// 
/// ## Критично
/// - **`fatalError` при ошибке создания `ModelContainer`**: для production это риск “жёсткого” падения при любой проблеме миграции/файловой системы. Понимаю, что в демо это допустимо, но для реального приложения лучше graceful recovery (например, сброс локальной базы с предупреждением).
/// 
/// ## Важно
/// - **`static shared` затрудняет тестирование**:
///   - Нельзя легко подменить контейнер на in-memory.
///   - Сложнее делать изолированные тесты persistence слоя.
/// 
/// ## Предложения
/// - Вынести фабрику `ModelContainer`/конфигурацию в DI.
/// - Добавить возможность `isStoredInMemoryOnly: true` для тестов.
/// - Обработать ошибки миграции отдельным сценарием (лог + очистка/backup).
/// 

import SwiftData

@MainActor
final class AppModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            PendingOperation.self,
            PersistentTransaction.self,
            PersistentCategory.self,
            PersistentBankAccount.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
