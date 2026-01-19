/// ## Ревью: `Financify/Persistence/BackupService.swift`
/// 
/// ## Критично
/// - **`BackupService` не является actor’ом, но используется из нескольких actor’ов** (`SynchronizationService`, `TransactionsService`, `BankAccountService`). При этом внутри хранится `ModelContext`, который в общем случае **не рассчитан на конкурентный доступ**. Это прямой риск гонок/крашей/повреждения локального стора.
/// 
/// ## Важно
/// - **API объявлен как `async throws`, но внутри полностью синхронный**:
///   - Это вводит в заблуждение и маскирует отсутствие изоляции.
///   - Либо сделать `BackupService` actor’ом, либо убрать `async` и обеспечить потокобезопасность другим способом.
/// - **Отсутствует явная стратегия ошибок SwiftData**: любые ошибки `save()` уходят наверх без контекста (что ок), но UI-слой часто просто `print`‑ит их.
/// 
/// ## Нюансы / стиль
/// - **Дублирующийся `import Foundation`** — мелочь, но стоит почистить.
/// 
/// ## Предложения
/// - Самый прямой вариант: **`final actor BackupService`** + изолированный `ModelContext` внутри актора.
/// - Альтернатива: выделенный serial executor/queue для всех операций со SwiftData в этом сервисе.
/// 

import Foundation
import SwiftData

import Foundation

protocol BackupServiceLogic {
    /// Добавляет новую операцию в очередь на синхронизацию.
    /// - Parameters:
    ///   - httpMethod: HTTP-метод запроса.
    ///   - endpointPath: Путь к эндпоинту.
    ///   - payload: Тело запроса (если есть)
    func add(httpMethod: String, endpointPath: String, payload: Data?) async throws
    
    /// Извлекает все отложенные операции, отсортированные по времени создания.
    func fetchAll() async throws -> [PendingOperation]
    
    /// Удаляет массив успешно синхронизированных операций.
    func delete(_ operations: [PendingOperation]) async throws
}

final class BackupService: BackupServiceLogic {
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
    }

    func add(httpMethod: String, endpointPath: String, payload: Data?) async throws {
        let operation = PendingOperation(
            httpMethod: httpMethod,
            endpointPath: endpointPath,
            payload: payload
        )
        modelContext.insert(operation)
        try modelContext.save()
    }

    func fetchAll() async throws -> [PendingOperation] {
        let descriptor = FetchDescriptor<PendingOperation>(sortBy: [SortDescriptor(\.timestamp, order: .forward)])
        return try modelContext.fetch(descriptor)
    }

    func delete(_ operations: [PendingOperation]) async throws {
        for operation in operations {
            modelContext.delete(operation)
        }
        try modelContext.save()
    }
}
