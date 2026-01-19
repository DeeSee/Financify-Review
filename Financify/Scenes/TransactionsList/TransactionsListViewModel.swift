/// ## Ревью: `Financify/Scenes/TransactionsList/TransactionsListViewModel.swift`
/// 
/// ## Критично
/// - **`selectedSortOption` триггерит полный `refresh()`**. Смена сортировки не должна заново ходить в сеть/БД — достаточно пересортировать уже загруженные данные. Сейчас это:
///   - увеличивает нагрузку,
///   - даёт лишние запросы,
///   - создаёт риск гонок (несколько refresh подряд).
/// - **Потенциальный крэш через `Currency(jsonTitle:)`**: при неизвестной валюте `Currency` делает `fatalError`.
/// 
/// ## Важно
/// - **Нет дедупликации/отмены refresh‑тасков**:
///   - `refresh()` может быть вызван из `.task`, `onDismiss`, смены сортировки, и из слушателя сети.
///   - При параллельных вызовах возможны out-of-order результаты и “мигание” UI.
/// - **Сортировка и фильтрация**:
///   - Категории уже запрашиваются через `getCategories(by: direction)`, но затем транзакции ещё раз фильтруются по `cat.isIncome`. Либо категории должны быть “все”, либо фильтрация дублируется.
/// - **Жёсткий период “сегодня” в VM**: VM всегда показывает только операции за сегодня. Это соответствует названию экрана, но это важно явно понимать (и, возможно, лучше конфигурировать).
/// 
/// ## Нюансы
/// - `endOfDay` строится через force unwrap — практически безопасно, но всё же лучше избегать `!` в вычислении дат.
/// - Ошибки ловятся и печатаются через `print`, но UI не получает сигнал “почему пусто”.
/// 
/// ## Предложения
/// - Разделить:
///   - `load()` (получить данные),
///   - `applySort()` (пересортировать локально),
///   - `applyFilter()` (локально).
/// - Ввести “token”/cancellation для refresh’ей (например, хранить `Task` и отменять предыдущий).
/// - Не падать на неизвестной валюте (см. `Currency_Review.md`).
/// 

import SwiftUI

@MainActor
final class TransactionsListViewModel: ObservableObject {
    // MARK: - Services
    let categoriesService: CategoriesServiceLogic
    let transactionsService: TransactionsServiceLogic
    let bankAccountService: BankAccountServiceLogic
    let reachability: NetworkReachabilityLogic
    
    // MARK: - Published
    @Published private(set) var categories: [Int:Category] = [:]
    @Published private(set) var transactions: [Transaction] = []
    
    @Published var isLoading: Bool = false
    @Published var isSyncing: Bool = false
    @Published var isOffline: Bool = false
    
    @Published var selectedSortOption: SortOption = .newestFirst {
        didSet {
            Task { await refresh() }
        }
    }
    
    @Published var currency: Currency = .rub
    
    // MARK: - Properties
    var total: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    let direction: Direction
    private var networkStatusTask: Task<Void, Never>? = nil
    
    // MARK: - Lifecycle
    init(direction: Direction,
         categoriesService: CategoriesServiceLogic,
         transactionsService: TransactionsServiceLogic,
         bankAccountService: BankAccountServiceLogic,
         reachability: NetworkReachabilityLogic
    ) {
        self.direction = direction
        self.categoriesService = categoriesService
        self.transactionsService = transactionsService
        self.bankAccountService = bankAccountService
        self.reachability = reachability
        
        self.isOffline = reachability.currentStatus == .offline
        
        listenForNetworkStatusChanges()
    }
    
    deinit {
        networkStatusTask?.cancel()
    }
    
    // MARK: - Methods
    func refresh() async {
        self.transactions = []
        
        if reachability.currentStatus == .online {
            isSyncing = true
        }
        isLoading = true
        
        defer {
            isLoading = false
            isSyncing = false
        }

        do {
            async let accountTask = bankAccountService.primaryAccount()
            async let categoriesTask = categoriesService.getCategories(by: direction)
            
            let (account, cats) = try await (accountTask, categoriesTask)
            
            self.currency = Currency(jsonTitle: account.currency)
            self.categories = Dictionary(uniqueKeysWithValues: cats.map { ($0.id, $0) })
            
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay   = calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
                
            let allToday = try await transactionsService.getAllTransactions(by: account.id) {
                (startOfDay...endOfDay).contains($0.transactionDate)
            }
            
            self.transactions = allToday.filter {
                guard let cat = categories[$0.categoryId] else { return false }
                return direction == .income ? cat.isIncome : !cat.isIncome
            }

            switch selectedSortOption {
            case .newestFirst:      transactions.sort { $0.transactionDate > $1.transactionDate }
            case .oldestFirst:      transactions.sort { $0.transactionDate < $1.transactionDate }
            case .amountDescending: transactions.sort { $0.amount > $1.amount }
            case .amountAscending:  transactions.sort { $0.amount < $1.amount }
            }
        } catch {
            print("Failed to refresh TransactionsListViewModel: \(error.localizedDescription)")
        }
    }
    
    func category(for transaction: Transaction) -> Category? {
        categories[transaction.categoryId]
    }
    
    // MARK: - Private Methods
    private func listenForNetworkStatusChanges() {
        networkStatusTask = Task(priority: .userInitiated) { @MainActor in
            for await status in reachability.statusStream {
                let wasOffline = self.isOffline
                self.isOffline = status == .offline
                
                if wasOffline && !self.isOffline {
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        await refresh()
                    }
                }
            }
        }
    }
}
