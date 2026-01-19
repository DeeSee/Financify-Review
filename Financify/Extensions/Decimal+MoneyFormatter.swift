/// ## Ревью: `Financify/Extensions/Decimal+MoneyFormatter.swift`
/// 
/// ## Критично
/// - **Глобальный `NumberFormatter`** (`decimalFormatter`) потенциально опасен:
///   - `Formatter`‑ы обычно **не потокобезопасны**. В проекте есть множество async/actor‑вызовов, и форматирование может случаться не только на главном потоке.
/// - **`maximumFractionDigits = 0`**: все суммы отображаются без копеек/центов. При наличии дробных значений в API это приводит к потере точности в UI и к странным эффектам при редактировании/сравнении.
/// 
/// ## Важно
/// - **Жёстко заданная локаль `ru_RU`** игнорирует реальные настройки пользователя. Если цель — всегда русский формат, ок, но тогда это должно быть осознанно и описано.
/// - `moneyFormatted` возвращает `""` при ошибке — это плохо для UI (лучше безопасный fallback, например `String(describing:)`).
/// 
/// ## Предложения
/// - Использовать `FormatStyle` (`Decimal.FormatStyle.Currency`) с ISO‑кодом валюты, либо создавать formatter на месте/кэшировать безопасно.
/// - Если дробная часть не нужна — хранить суммы как целые (minor units) или явно округлять, но не “молчаливо” обрезать при форматировании.
/// 

import Foundation

let decimalFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.maximumFractionDigits = 0
    f.groupingSeparator = " "
    f.locale = Locale(identifier: "ru_RU")
    return f
}()

extension Decimal {
    var moneyFormatted: String {
        decimalFormatter.string(from: self as NSDecimalNumber) ?? ""
    }
    
    func moneyFormatted(with currencyCode: String) -> String {
        "\(moneyFormatted) \(currencyCode)"
    }
}
