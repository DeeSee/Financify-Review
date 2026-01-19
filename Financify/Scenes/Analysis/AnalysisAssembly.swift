/// ## Ревью: `Financify/Scenes/Analysis/AnalysisAssembly.swift`
/// 
/// ## Что хорошо
/// - Чистая сборка VIP‑модуля: создаётся presenter/interactor/view и связываются зависимости.
/// 
/// ## Нюансы
/// - `AnalysisAssembly` помечен `@MainActor`, но создаёт `AnalysisInteractor`, который сам не `@MainActor`/не actor и будет жить в конкурентном мире async задач.
/// 
/// ## Предложения
/// - `AnalysisInteractor` хранит mutable state и вызывается из UI‑контекста (`UIViewController` lifecycle + UIActions), поэтому его стоит сделать сериализованным: `@MainActor` (или `actor`), чтобы компилятор/модель конкурентности защищали от гонок.
/// 

import UIKit

@MainActor
enum AnalysisAssembly {
    static func build(
        direction: Direction,
        categoriesService: CategoriesServiceLogic,
        transactionsService: TransactionsServiceLogic,
        bankAccountService: BankAccountServiceLogic,
        reachability: NetworkReachabilityLogic,
        onClose: @escaping () -> Void
    ) -> UIViewController {
        let presenter = AnalysisPresenter()
        let interactor = AnalysisInteractor(
            presenter: presenter,
            direction: direction,
            categoriesService: categoriesService,
            transactionsService: transactionsService,
            bankAccountService: bankAccountService,
            reachability: reachability
        )
        let view = AnalysisViewController(interactor: interactor)
        view.onClose = onClose
        presenter.view = view
        
        return view
    }
}
