/// ## Ревью: `Financify/Services/CategoriesService.swift`
/// 
/// ## Важно
/// - **`updateLocalStore` делает wipe категорий** (delete all + insert all). Для справочника категорий это обычно ок, но:
///   - если появится локальное состояние/пользовательские категории — это станет проблемой.
///   - wipe может быть дорогим при большом объёме/частых обновлениях.
/// - **Сервис держит `ModelContext` внутри actor’а** — это хороший шаг (изоляция), но важно, чтобы контекст не “утекал” наружу.
/// 
/// ## Нюансы
/// - `reachability` инжектится, но сейчас напрямую не используется (всегда пробуем сеть и fallback). Либо убрать зависимость, либо использовать для оптимизации/UX (например, не стартовать сетевой запрос, если offline).
/// - `client` объявлен `let` без `private` — мелочь.
/// 
/// ## Предложения
/// - Рассмотреть upsert по `id` вместо полного wipe.
/// - Добавить простое кэширование/TTL, чтобы не дёргать категории слишком часто (они редко меняются).
/// 

import Foundation
import SwiftData

protocol CategoriesServiceLogic: Actor {
    func getAllCategories() async throws -> [Category]
    func getCategories(by direction: Direction) async throws -> [Category]
}

final actor CategoriesService: CategoriesServiceLogic {
    // MARK: - DI
    let client: NetworkClient
    private let reachability: NetworkReachabilityLogic
    private let modelContext: ModelContext
    
    // MARK: - Lifecycle
    init(
        client: NetworkClient = NetworkClient(),
        reachability: NetworkReachabilityLogic,
        modelContainer: ModelContainer
    ) {
        self.client = client
        self.reachability = reachability
        self.modelContext = ModelContext(modelContainer)
    }
    
    // MARK: - Methods
    func getAllCategories() async throws -> [Category] {
        do {
            let categories: [Category] = try await client.request(.categoriesGET, method: .get)
            try await updateLocalStore(with: categories)
            return categories
        } catch {
            print("Categories fetch failed. Falling back to local data. Error: \(error.localizedDescription)")
            return try await fetchLocalCategories()
        }
    }
    
    func getCategories(by direction: Direction) async throws -> [Category] {
        let allCategories = try await getAllCategories()
        return allCategories.filter { $0.direction == direction }
    }
    
    // MARK: - Private Methods
    private func fetchLocalCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<PersistentCategory>()
        let persistent = try modelContext.fetch(descriptor)
        return persistent.map { $0.toDomain() }
    }
    
    private func updateLocalStore(with categories: [Category]) async throws {
        try modelContext.delete(model: PersistentCategory.self)
        try modelContext.save()
        
        for category in categories {
            modelContext.insert(PersistentCategory(from: category))
        }
        try modelContext.save()
    }
}
