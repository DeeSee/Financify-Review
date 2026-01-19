/// ## Ревью: `Financify/Utils/ShakeGesture.swift`
/// 
/// ## Важно
/// - **`becomeFirstResponder()` в `didMoveToWindow`**:
///   - Такой view может “перехватывать” first responder и потенциально мешать вводу в текстовые поля на экране.
///   - Нет явного `resignFirstResponder` при уходе view с экрана.
/// - **SwiftUI `.background(ShakeGestureView(...))`**:
///   - Удобно, но важно понимать, что это вставляет UIKit‑view в иерархию и может иметь сайд‑эффекты (ресайн first responder, события motion).
/// 
/// ## Предложения
/// - Делать `becomeFirstResponder` более осторожно (например, только когда реально нужен shake, и не на всех экранах).
/// - Добавить `resignFirstResponder` при `didMoveToWindow` (window == nil) или `willMove(toWindow:)`.
/// 

import SwiftUI

struct ShakeGestureModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .background(ShakeGestureView(onShake: action))
    }
}

extension View {
    public func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeGestureModifier(action: action))
    }
}

private struct ShakeGestureView: UIViewRepresentable {
    let onShake: () -> Void
    
    func makeUIView(context: Context) -> ShakeRespondingView {
        let view = ShakeRespondingView()
        view.onShake = onShake
        return view
    }

    func updateUIView(_ uiView: ShakeRespondingView, context: Context) {}
}

private class ShakeRespondingView: UIView {
    var onShake: () -> Void = {}
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake()
        }
        super.motionEnded(motion, with: event)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        becomeFirstResponder()
    }
}
