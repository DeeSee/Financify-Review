/// ## Ревью: `Financify/Utils/AppDependencies.swift`
/// 
/// ## Важно
/// - **DI жёстко зашит в `init()`**:
///   - Удобно для демо, но сильно ухудшает тестируемость (нельзя легко подменить сервисы на моки).
///   - Переиспользование/конфигурирование окружений (dev/stage/prod) тоже усложняется.
/// - **Нейминг**: `transactionService` (singular) при типе `TransactionsServiceLogic` (plural) — мелочь, но лучше выровнять (`transactionsService`).
/// 
/// ## Нюансы
/// - `@MainActor` на контейнере зависимостей — ок для SwiftUI, но важно понимать: сервисы внутри — actor’ы/Sendable, и DI‑контейнер не должен брать на себя их потоковую изоляцию.
/// 
/// ## Предложения
/// - Добавить второй инициализатор с явными параметрами (для тестов/preview).
/// - Вынести конфиг (baseURL, флаги) в отдельную структуру `AppConfig` и инжектить её.
/// 

import SwiftUI
import SwiftData

@MainActor
final class AppDependencies: ObservableObject {
    let bankAccountService: BankAccountServiceLogic
    let transactionService: TransactionsServiceLogic
    let categoryService: CategoriesServiceLogic
    let backupService: BackupServiceLogic
    let networkReachabilityService: NetworkReachabilityLogic
    let synchronizationService: SynchronizationServiceLogic
        
    let modelContainer: ModelContainer
    
    init() {
        self.modelContainer = AppModelContainer.shared
        
        self.networkReachabilityService = NetworkReachabilityService()
        self.backupService = BackupService(modelContainer: self.modelContainer)
        self.synchronizationService = SynchronizationService(
            backupService: self.backupService,
            reachability: self.networkReachabilityService
        )
        self.transactionService = TransactionsService(
            synchronizationService: self.synchronizationService,
            backupService: self.backupService,
            reachability: self.networkReachabilityService,
            modelContainer: self.modelContainer
        )
        self.categoryService = CategoriesService(
            reachability: self.networkReachabilityService,
            modelContainer: self.modelContainer
        )
        self.bankAccountService = BankAccountService(
            synchronizationService: self.synchronizationService,
            backupService: self.backupService,
            reachability: self.networkReachabilityService,
            modelContainer: self.modelContainer
        )
    }
}
