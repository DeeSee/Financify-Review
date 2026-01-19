/// ## Ревью: `Financify/Scenes/SpoilerView.swift`
/// 
/// ## Важно
/// - `SpoilerModifier` всегда накладывает `SpoilerView` как overlay, даже когда `isOn == false` (просто `birthRate = 0`).
///   - Это может быть чуть тяжелее по ресурсам, чем условно добавлять/убирать overlay.
/// 
/// ## Нюансы
/// - `emitterCell.birthRate = 400` и затем `uiView.layer.birthRate = isOn ? 1 : 0` — важно понимать, что итоговая интенсивность = произведение/эффективное значение на уровне слоя/ячейки. Сейчас выглядит как “работает”, но легко получить слишком тяжёлую анимацию на старых устройствах.
/// - `.onTapGesture` переключает спойлер — ок, но стоит проверить совместимость с другими жестами.
/// 
/// ## Предложения
/// - Добавлять overlay только когда `isOn == true`.
/// - Подобрать параметры эмиттера под производительность (и, возможно, уменьшить birthRate).
/// 

import SwiftUI

final class EmitterView: UIView {

    override class var layerClass: AnyClass {
        CAEmitterLayer.self
    }

    override var layer: CAEmitterLayer {
        super.layer as! CAEmitterLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.emitterPosition = .init(x: bounds.size.width / 2,
                                      y: bounds.size.height / 2)
        layer.emitterSize = bounds.size
    }
}

struct SpoilerView: UIViewRepresentable {

    var isOn: Bool

    func makeUIView(context: Context) -> EmitterView {
        let emitterView = EmitterView()

        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "textSpeckle_Normal")?.cgImage
        emitterCell.color = UIColor.gray.cgColor
        emitterCell.contentsScale = 1.8
        emitterCell.emissionRange = .pi * 2
        emitterCell.lifetime = 1
        emitterCell.scale = 0.5
        emitterCell.velocityRange = 20
        emitterCell.alphaRange = 1
        emitterCell.birthRate = 400

        emitterView.layer.emitterShape = .rectangle
        emitterView.layer.emitterCells = [emitterCell]

        return emitterView
    }

    func updateUIView(_ uiView: EmitterView, context: Context) {
        if isOn {
            uiView.layer.beginTime = CACurrentMediaTime()
        }
        uiView.layer.birthRate = isOn ? 1 : 0
    }
}

struct SpoilerModifier: ViewModifier {

    let isOn: Bool

    func body(content: Content) -> some View {
        content.overlay {
            SpoilerView(isOn: isOn)
        }
    }
}

extension View {

    func spoiler(isOn: Binding<Bool>) -> some View {
        self
            .opacity(isOn.wrappedValue ? 0 : 1)
            .modifier(SpoilerModifier(isOn: isOn.wrappedValue))
            .animation(.default, value: isOn.wrappedValue)
            .onTapGesture {
                isOn.wrappedValue.toggle()
            }
    }
}
