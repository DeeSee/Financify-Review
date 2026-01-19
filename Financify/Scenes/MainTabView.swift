/// ## Ревью: `Financify/Scenes/MainTabView.swift`
/// 
/// ## Важно
/// - **Сайд‑эффекты в `init()` SwiftUI View**: настройка `UITabBar.appearance()` выполняется при каждом создании `MainTabView` (включая Preview).
///   - Обычно лучше делать это один раз (например, в `App` инициализации).
/// - **DI смешан**: есть `@EnvironmentObject dependencies`, но зависимости дальше прокидываются вручную в конструкторы экранов. Это не плохо, но можно упростить и выровнять подход.
/// 
/// ## Нюансы
/// - Строки табов (“Счёт”, “Статьи”, “Настройки”) — захардкожены, а локализация в проекте частично есть.
/// 
/// ## Предложения
/// - Перенести настройку appearance в более глобальную точку (например, `FinancifyApp`).
/// - Решить, будет ли DI через environment или через явные параметры, и быть последовательным.
/// 

import SwiftUI

struct MainTabView: View {
    // MARK: - Properties
    @EnvironmentObject private var dependencies: AppDependencies
    
    // MARK: - Lifecycle
    init() {
        // Фон таббара
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(named: "tabBarColor")
        tabAppearance.shadowColor = .separator
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }
    
    var body: some View {
        TabView {
            // Расходы
            TransactionsListView(
                direction: .outcome,
                categoriesService: dependencies.categoryService,
                transactionsService: dependencies.transactionService,
                bankAccountService: dependencies.bankAccountService,
                reachability: dependencies.networkReachabilityService
            )
                .tabItem {
                    Image(.downtrend)
                        .renderingMode(.template)
                    Text(Direction.outcome.tabTitle) }
            
            // Доходы
            TransactionsListView(
                direction: .income,
                categoriesService: dependencies.categoryService,
                transactionsService: dependencies.transactionService,
                bankAccountService: dependencies.bankAccountService,
                reachability: dependencies.networkReachabilityService
            )
                .tabItem {
                    Image(.uptrend)
                        .renderingMode(.template)
                    
                    Text(Direction.income.tabTitle) }
            
            // Счет
            BalanceView(
                bankAccountService: dependencies.bankAccountService,
                transactionsService: dependencies.transactionService,
                categoriesService: dependencies.categoryService,
                reachability: dependencies.networkReachabilityService
            )
                .tabItem {
                    Image(.calculator)
                        .renderingMode(.template)
                    
                    Text("Счёт") }
            
            // Статьи
            CategoriesView(
                categoriesService: dependencies.categoryService,
                reachability: dependencies.networkReachabilityService
            )
                .tabItem {
                    Image(.categories)
                        .renderingMode(.template)
                    
                    Text("Статьи") }
            
            // Настройки
            Text("Настройки")
                .tabItem {
                    Image(.gear)
                        .renderingMode(.template)
                    
                    Text("Настройки") }
        }
        .tint(.accent)
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environmentObject(AppDependencies())
}
