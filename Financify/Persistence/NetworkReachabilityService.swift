/// ## Ревью: `Financify/Persistence/NetworkReachabilityService.swift`
/// 
/// ## Важно
/// - **`statusStream` хранит только одну `continuation`**: реализация поддерживает только одного подписчика; второй подписчик перезапишет `continuation`.
/// - **QoS очереди `NWPathMonitor` = `.userInteractive`** — это слишком высокий приоритет для мониторинга сети. Обычно достаточно `.utility` или `.background`.
/// - **`currentStatus` вычисляется через `usesInterfaceType`**. Более устойчиво опираться на `path.status == .satisfied` и дополнительно учитывать интерфейсы (wifi/cellular) как уточнение.
/// 
/// ## Нюансы
/// - **`didSet` спавнит `Task { @MainActor ... }` для yield**. Это добавляет лишнюю асинхронность и может менять порядок событий; `yield` можно делать напрямую, а доставку на MainActor оставлять потребителю потока.
/// - **`print` в проде**: лучше перейти на `Logger`.
/// 
/// ## Предложения
/// - Хранить коллекцию continuations (или сделать отдельный broadcaster), либо документировать “только один подписчик”.
/// - Снизить QoS.
/// - Добавить unit-тест/интеграционный тест на “переход offline→online” (подписчики, отмена таски).
/// 

import Foundation
import Network

final class NetworkReachabilityService: NetworkReachabilityLogic {
    
    // MARK: - Properties
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.financify.network-monitor", qos: .userInteractive)
    
    private var continuation: AsyncStream<NetworkStatus>.Continuation?
    
    private(set) var currentStatus: NetworkStatus = .offline {
        didSet {
            Task { @MainActor in
                continuation?.yield(currentStatus)
            }
        }
    }

    lazy var statusStream: AsyncStream<NetworkStatus> = {
        AsyncStream { continuation in
            self.continuation = continuation
            Task { @MainActor in
                self.continuation?.yield(self.currentStatus)
            }
        }
    }()

    // MARK: - Lifecycle
    init() {
        self.monitor = NWPathMonitor()
        self.currentStatus = monitor.currentPath.usesInterfaceType(.wifi) || monitor.currentPath.usesInterfaceType(.cellular) ? .online : .offline
        self.startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Private Methods
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            if path.status == .satisfied && (path.usesInterfaceType(.wifi) || path.usesInterfaceType(.cellular)) {
                print("Network connection [ONLINE] detected via Wi-Fi or Cellular.")
                self.currentStatus = .online
            } else {
                print("Network connection [OFFLINE].")
                self.currentStatus = .offline
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
}
