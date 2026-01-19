/// ## Ревью: `Financify/Scenes/TransactionEditor/Additional Views/CustomDatePickerStyle.swift`
/// 
/// ## Нюансы
/// - В `makeBody` две ветки (`if let range`) почти полностью дублируют друг друга. Можно упростить и сделать один `DatePicker`, а `in:` добавлять условно.
/// - Стилизация (`.background(.thirdAccent).cornerRadius(8)`) применяется к `DatePicker` — важно проверять на разных версиях iOS, потому что нативный `DatePicker` часто ведёт себя по‑разному.
/// 
/// ## Предложения
/// - Упростить код, убрав дублирование.
/// - Вынести цвета/радиусы в дизайн‑константы, чтобы стиль был единообразным на всех экранах.
/// 

import SwiftUI

struct CustomDatePickerStyle: DatePickerStyle {
    let range: PartialRangeThrough<Date>?

    init(range: PartialRangeThrough<Date>? = nil) {
        self.range = range
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            if let range = range {
                DatePicker(
                    "",
                    selection: configuration.$selection,
                    in: range,
                    displayedComponents: configuration.displayedComponents
                )
                .tint(.accent)
                .labelsHidden()
                .background(.thirdAccent)
                .cornerRadius(8)
            } else {
                DatePicker(
                    "",
                    selection: configuration.$selection,
                    displayedComponents: configuration.displayedComponents
                )
                .tint(.accent)
                .labelsHidden()
                .background(.thirdAccent)
                .cornerRadius(8)
            }
        }
    }
}
