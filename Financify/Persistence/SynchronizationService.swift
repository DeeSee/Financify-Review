/// ## Ревью: `Financify/Persistence/SynchronizationService.swift`
/// 
/// ## Критично
/// - **Политика “все 4xx = фатально удалить операцию” опасна**:
///   - 401/403 могут означать проблему авторизации (токен/ключ), и удаление очереди приведёт к **потере пользовательских изменений**.
///   - 409/412 — возможные конфликты/прекаундишены, которые обычно требуют разрешения, а не silent drop.
///   - 429 — rate limit, это точно не “фатально”.
/// - **Нет reconciliation для POST**: операции синхронизации выполняются через `requestStatus(with:)`, т.е. ответ (и id созданной сущности) не используется. В проекте офлайн‑POST создаёт локальные транзакции с временным id (см. `TransactionsService.saveToAdd`), поэтому сопоставление temp id ↔ server id сейчас не выполняется.
/// 
/// ## Важно
/// - **Сохранение порядка и зависимостей операций**:
///   - Сейчас цикл продолжает синхронизацию даже после временных ошибок. Если операции логически зависят друг от друга, разумнее либо останавливаться на первой ошибке, либо группировать по сущности.
/// - **Чувствительность к смене сети во время синка**: проверка `reachability.currentStatus == .online` делается один раз. Если сеть отвалилась в середине, будет много ошибок и шумных логов.
/// - **Сборка URL из `endpointPath` строкой**: удобно, но без валидации можно получить некорректные пути. Как минимум стоит ограничить набор допустимых префиксов/endpoint’ов.
/// 
/// ## Нюансы
/// - **Логи через `print`**: для production лучше `Logger` + уровни.
/// - **`HTTPMethod(rawValue:)`**: если когда-то в `PendingOperation.httpMethod` попадёт неожиданный метод, запрос может уйти с `nil` методом/неожиданным значением — стоит валидировать.
/// 
/// ## Предложения
/// - Развести классы ошибок: **Auth / RateLimit / Conflict / ClientValidation / Server / Network** и по-разному решать судьбу операции в очереди.
/// - Для POST — использовать запрос, возвращающий тело, чтобы получить server id и обновить локальные данные.
/// 

import Foundation
import Alamofire

protocol SynchronizationServiceLogic: Actor {
    func synchronize() async
}

final actor SynchronizationService: SynchronizationServiceLogic {
    private let backupService: BackupServiceLogic
    private let reachability: NetworkReachabilityLogic
    private let client: NetworkClient

    init(
        backupService: BackupServiceLogic,
        reachability: NetworkReachabilityLogic,
        client: NetworkClient = NetworkClient()
    ) {
        self.backupService = backupService
        self.reachability = reachability
        self.client = client
    }

    func synchronize() async {
        guard reachability.currentStatus == .online else { return }

        do {
            let pending = try await backupService.fetchAll()
            guard !pending.isEmpty else { return }

            print("SynchronizationService: Starting synchronization of \(pending.count) pending operations.")

            var successfulOps: [PendingOperation] = []
            var fatalOps: [PendingOperation] = [] // Список для невыполнимых операций

            for operation in pending {
                do {
                    let method = HTTPMethod(rawValue: operation.httpMethod)
                    let url = APIEndpoint.baseURL.appendingPathComponent(operation.endpointPath)
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpBody = operation.payload
                    urlRequest.method = method
                    if operation.payload != nil {
                        urlRequest.headers.add(.contentType("application/json"))
                    }

                    _ = try await client.requestStatus(with: urlRequest)
                    
                    // Если запрос прошел без ошибок, добавляем операцию в список на удаление
                    successfulOps.append(operation)
                    print("SynchronizationService: Successfully synced operation for path \(operation.endpointPath).")
                } catch let error as NetworkError {
                    // Анализируем тип ошибки
                    if case .serverError(let statusCode, _) = error, (400...499).contains(statusCode) {
                        // Это фатальная ошибка клиента (400, 404)
                        print("SynchronizationService: Encountered fatal error (status \(statusCode)) for operation on path \(operation.endpointPath). Discarding operation.")
                        fatalOps.append(operation)
                    } else {
                        // Это временная ошибка (5xx) - ничего не делаем, попробуем позже
                        print("SynchronizationService: Encountered temporary error for operation on path \(operation.endpointPath). Will retry later. Error: \(error.localizedDescription)")
                    }
                } catch {
                    // Любая другая временная ошибка
                    print("SynchronizationService: Encountered temporary error for operation on path \(operation.endpointPath). Will retry later. Error: \(error.localizedDescription)")
                }
            }

            // Удаляем и успешные, и фатальные операции
            let opsToDelete = successfulOps + fatalOps
            if !opsToDelete.isEmpty {
                try await backupService.delete(opsToDelete)
                print("SynchronizationService: Deleted \(opsToDelete.count) processed operations (\(successfulOps.count) successful, \(fatalOps.count) fatal).")
            }

        } catch {
            print("SynchronizationService: A critical error occurred during synchronization fetch: \(error)")
        }
    }
}
