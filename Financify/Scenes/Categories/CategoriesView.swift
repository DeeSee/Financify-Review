/// ## Ревью: `Financify/Scenes/Categories/CategoriesView.swift`
/// 
/// ## Важно
/// - Много UI‑строк захардкожено (“Мои статьи”, “СТАТЬИ”, “Поиск статей”) — лучше локализовать.
/// - `suggestions` строятся по тому же `fuzzyMatch`, что и фильтрация — см. производительность в `CategoriesViewModel_Review.md`.
/// 
/// ## Нюансы
/// - При загрузке показывается `LoadingAnimation` только если `categories.isEmpty`. Если был старый список и идёт обновление, индикатор не показывается (может быть ок, но важно осознавать UX).
/// 

import SwiftUI

struct CategoriesView: View {
    // MARK: - Properties
    @StateObject private var viewModel: CategoriesViewModel
    
    // MARK: - Lifecycle
    init(categoriesService: CategoriesServiceLogic,
         reachability: NetworkReachabilityLogic
    ) {
        let vm = CategoriesViewModel(
            categoriesService: categoriesService,
            reachability: reachability
        )
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(String.categoriesSectionTitle) {
                    ForEach(viewModel.filteredCategories) { category in
                        CategoryCell(
                            category: category
                        )
                    }
                }
            }
            .overlay(alignment: .center) {
                // Пока данные грузятся - показываем анимацию загрузки по центру экрана
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    LoadingAnimation()
                }
            }
            .overlay(alignment: .bottom) {
                if viewModel.isOffline {
                    OfflineBannerView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(String.categoriesTitle)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Поиск статей"
            ) {
                // Подсказки при поиске
                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                    Text(suggestion).searchCompletion(suggestion)
                }
            }
            .task {
                await viewModel.fetchCategories()
            }
        }
    }
}

// MARK: - Constants
fileprivate extension String {
    static let categoriesTitle: String = "Мои статьи"
    static let categoriesSectionTitle: String = "СТАТЬИ"
}
