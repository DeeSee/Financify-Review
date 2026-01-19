/// ## Ревью: `Financify/Scenes/Categories/CategoryCell.swift`
/// 
/// ## Нюансы
/// - В `alignmentGuide(.listRowSeparatorLeading)` используется “магическое” число `+ 36`. Лучше вынести в константу с объяснением, чтобы было проще поддерживать.
/// - Ячейка отображает только имя категории; если нужны дополнительные атрибуты (тип доход/расход) — придётся расширять.
/// 

import SwiftUI

struct CategoryCell: View {
    // MARK: - Properties
    let category: Category
    
    var body: some View {
        HStack(alignment: .center) {
            Text(String(category.emoji))
                .font(.system(size: .emojiFontSize))
                .padding(.emojiPadding)
                .background(Circle().fill(.thirdAccent))
            
            VStack(alignment: .leading) {
                Text(category.name)
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            return viewDimensions[.listRowSeparatorLeading] + 36
        }
    }
}

// MARK: - Constants
fileprivate extension CGFloat {
    static let emojiFontSize: CGFloat = 20
    static let emojiPadding: CGFloat = 4
}
