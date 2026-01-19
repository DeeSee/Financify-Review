/// ## Ревью: `Financify/Scenes/Analysis/Additional Views/ChartCell.swift`
/// 
/// ## Нюансы
/// - В constraints одновременно задаётся `width == height` и `width == 220`. Это валидно (получится квадрат 220x220), но лучше оставить это очевидным комментарием — иначе выглядит как “случайный набор”.
/// - `backgroundColor = .clear` у ячейки — ок, но важно проверять на разных стилях таблицы (`insetGrouped`) и темах.
/// 

import UIKit
import PieChart

final class ChartCell: UITableViewCell {
    private let chartView = PieChartView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(chartView)
        chartView.pinTop(to: contentView.topAnchor, 8)
        chartView.pinBottom(to: contentView.bottomAnchor, 8)
        chartView.pinCenterX(to: contentView.centerXAnchor)
        chartView.pinWidth(to: chartView.heightAnchor)
        chartView.setWidth(220)
        selectionStyle = .none
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with entities: [Entity], animated: Bool = false) {
        if animated {
            chartView.animateUpdate(to: entities)
        } else {
            chartView.transform = .identity
            chartView.alpha = 1.0
            chartView.entities = entities
        }
    }
}
