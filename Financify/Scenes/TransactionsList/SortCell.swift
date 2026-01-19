/// ## Ревью: `Financify/Scenes/TransactionsList/SortCell.swift`
/// 
/// ## Важно
/// - Сортировка отображает `SortOption.rawValue` (текст), который сейчас жёстко зашит в enum. При локализации лучше держать ключи/локализованные строки отдельно (см. `SortOption_Review.md`).
/// 
/// ## Нюансы
/// - Preview закомментирован. Лучше либо удалить, либо довести до рабочего состояния — помогает при рефакторинге UI.
/// 

import SwiftUI

struct SortCell: View {
    @Binding var selectedOption: SortOption
    
    var body: some View {
        HStack {
            Text(String.sortTitle)
            Spacer()
            Menu {
                ForEach(SortOption.allCases) { option in
                    Button {
                        selectedOption = option
                    } label: {
                        HStack {
                            Text(option.rawValue)
                            Spacer()
                            Image(systemName: option.iconName)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedOption.rawValue)
                    Image(systemName: "chevron.down")
                }
            }
            .tint(.accent)
        }
    }
}

// MARK: - Constants
fileprivate extension String {
    static let sortTitle: String = "Сортировка"
}

// MARK: - Preview
#Preview {
//    @State var selectedOption: SortOption = .amountAscending
//    SortCell(selectedOption: $selectedOption)
}
