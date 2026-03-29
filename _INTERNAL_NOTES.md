# Financify — Internal Project Notes

## Project Overview
iOS personal finance app (Swift 6.1, iOS 15+). Manages bank accounts, transactions, categories.
Backend: REST API at `https://shmr-finance.ru/api/v1/`.

## Architecture
- **SwiftUI + MVVM** for most screens (Balance, Categories, History, TransactionsList, TransactionEditor).
- **UIKit + VIP (Clean Swift)** for Analysis screen.
- **Hybrid bridge** via `UIViewControllerRepresentable` (AnalysisViewControllerWrapper in HistoryView).
- Two local Swift packages: `LaunchAnimation` (Lottie), `Utilities` (PieChart).

## Key Design Decisions
1. **Offline-First**: SwiftData local store + PendingOperation queue + SynchronizationService replay.
2. **Single primary account model**: App always works with `accounts.first` — no multi-account support.
3. **Categories come from server**: No local category creation.
4. **API token via xcconfig -> Info.plist**: `Bundle.main.object(forInfoDictionaryKey: "API_KEY")`.

## Dependency Graph
```
FinancifyApp
 └── AppDependencies (DI container, @MainActor)
      ├── NetworkReachabilityService
      ├── BackupService (SwiftData PendingOperation)
      ├── SynchronizationService (actor, replays pending ops)
      ├── BankAccountService (actor)
      ├── TransactionsService (actor)
      └── CategoriesService (actor)
```

## Data Flow
1. ViewModels call service actors
2. Service actors call NetworkClient (Alamofire) + local SwiftData
3. On failure, operations queued in BackupService
4. SynchronizationService replays queue on reconnect

## Key Files by Concern
- Networking: `Networking.swift` (NetworkClient, APIEndpoint, NetworkError)
- Domain: `BankAccount`, `Transaction`, `Category`, `CategorySummary`
- DTOs: `AccountBrief/Response/CreateRequest/UpdateRequest/History/HistoryResponse/State`, `TransactionRequest/Response`, `StatItem`
- Persistence: `PersistentBankAccount/Transaction/Category`, `PendingOperation`, `BackupService`, `SynchronizationService`
- Services: `BankAccountService`, `TransactionsService`, `CategoriesService`

## Critical Bugs Found
1. `BankAccount.encode` uses `String(describing:)` — locale-dependent
2. `Currency.init(jsonTitle:)` calls `fatalError` on unknown currency
3. `LocalizationManager` force-unwraps bundle path
4. `PersistentCategory.emoji` force-unwraps `.first!`
5. `NetworkReachabilityService` is not Sendable but protocol requires it
6. `AFError.underlyingData` extension always returns nil
7. `HistoryViewModel` date setters can cause double refresh
8. `commitTotalEdit` strips decimal separators — fractional amounts impossible
9. `TransactionsService.saveToAdd` userInfo key never read by encoder
10. `AnalysisInteractor` mutates state from background without actor isolation
