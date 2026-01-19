/// ## Ревью: `Financify/Extensions/UIColor+Hex.swift`
/// 
/// ## Важно
/// - **Нет валидации входной строки**:
///   - `Scanner.scanHexInt64` может не распарсить строку, но код не проверяет результат; `rgb` останется 0 и вернётся чёрный цвет без явного сигнала об ошибке.
/// - **Нет поддержки альфы** (в отличие от `Color(hex:)`).
/// - Дублирование логики с `Color+Hex.swift`.
/// 
/// ## Предложения
/// - Сделать поведение единообразным с `Color(hex:)`:
///   - валидировать длину,
///   - возвращать fallback (.clear/black) осознанно,
///   - добавить поддержку `#RRGGBBAA` при необходимости.
/// 

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String) {
        // Убираем пробелы и \n, делаем строку заглавной
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // По стандарту HEX имеет # в начале, - убираем
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        // Преобразуем HEX-строку в число
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        // Извлекаем компоненты красного, зеленого и синего из числа
        // & (побитовое и) “вытаскивает” FF символы, которые представляют цвета
        // Далее цвет сдвигается на 16/8/0 битов вправо, чтобы получить значение в диапазоне 0...255
        let dividerToRgb = 255.0
        let red = CGFloat((rgb & 0xFF0000) >> 16) / dividerToRgb
        let green = CGFloat((rgb & 0x00FF00) >> 8) / dividerToRgb
        let blue = CGFloat(rgb & 0x0000FF) / dividerToRgb
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
