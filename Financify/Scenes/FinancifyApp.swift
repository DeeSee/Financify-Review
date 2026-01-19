/// ## Ревью: `Financify/Scenes/FinancifyApp.swift`
/// 
/// ## Важно
/// - **Двойная анимация**: на `MainTabView` и на `LaunchAnimationView` стоят `.animation(..., value: showLaunchAnimation)`. Это может приводить к избыточным анимациям/непредсказуемости перехода.
/// - **MainTabView под `opacity(0)`**: если бы оверлей не перекрывал всё, невидимый view мог бы продолжать принимать события. Сейчас `LaunchAnimationView` `ignoresSafeArea()` и поверх — вероятно ок, но это тонкий момент.
/// 
/// ## Предложения
/// - Держать анимацию в одном месте (либо через `withAnimation` при переключении флага, либо через один `.animation`).
/// - При необходимости явно блокировать интеракции под лонч‑анимацией (`.allowsHitTesting(!showLaunchAnimation)`).
/// 

import SwiftUI
import LaunchAnimation

@main
struct FinancifyApp: App {
    @StateObject private var dependencies = AppDependencies()
    @State private var showLaunchAnimation = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(dependencies)
                    .modelContainer(dependencies.modelContainer)
                    .opacity(showLaunchAnimation ? 0 : 1)
                    .animation(.easeOut(duration: 0.5), value: showLaunchAnimation)
                
                if showLaunchAnimation {
                    LaunchAnimationView {
                        showLaunchAnimation = false
                    }
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.5), value: showLaunchAnimation)
                }
            }
        }
    }
}
