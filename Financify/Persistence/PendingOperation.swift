/// ## Ревью: `Financify/Persistence/PendingOperation.swift`
/// 
/// ## Критично
/// - **`@Model final class PendingOperation: Sendable`**: пометка SwiftData-модели как `Sendable` выглядит опасно. `@Model`-объекты — reference‑типы, управляемые SwiftData, и их “безусловная” Sendable‑гарантия может быть неверной и скрывать реальные проблемы конкурентности.
/// 
/// ## Важно
/// - **`endpointPath` как произвольная строка**:
///   - Удобно для реплея, но легко получить “мусорные” значения.
///   - Стоит либо ограничить значения (enum/typed endpoint), либо хранить структурировано (endpoint + id).
/// - **`payload: Data?` в SwiftData**:
///   - Может быть большим, увеличивает размер стора.
///   - Может содержать чувствительные данные (в зависимости от API) — важно понимать требования к безопасности.
/// 
/// ## Нюансы
/// - **`httpMethod` хранится строкой** — лучше типизировать, хотя бы через enum, чтобы не ловить неожиданное значение на синхронизации.
/// 
/// ## Предложения
/// - Убрать `Sendable` с `@Model` либо перейти на модель/DTO, который реально Sendable и хранится отдельно от SwiftData-объекта.
/// - Ввести “тип операции”: `{ entityType, action, entityId?, payload }`, чтобы синк мог умнее разрешать конфликты.
/// 

import Foundation
import SwiftData

@Model
final class PendingOperation: Sendable {
    @Attribute(.unique)
    var id: UUID
    
    var timestamp: Date
    
    var httpMethod: String
    
    var endpointPath: String
    
    var payload: Data?

    init(httpMethod: String, endpointPath: String, payload: Data? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.httpMethod = httpMethod
        self.endpointPath = endpointPath
        self.payload = payload
    }
}
