# SpoilerView.swift — Code Review

## Замечания

### 1. `EmitterView` — `final class`, но `layerClass` override (строки 3–11)
`EmitterView` помечен `final`, но переопределяет `layerClass` и `layer`. Это работает (override class property не зависит от subclassing), но `final` тут не несёт пользы и может запутать.

### 2. `spoiler(isOn:)` принимает `Binding`, но `SpoilerModifier` — `Bool` (строки 66–75)
```swift
func spoiler(isOn: Binding<Bool>) -> some View {
    self
        .opacity(isOn.wrappedValue ? 0 : 1)
        .modifier(SpoilerModifier(isOn: isOn.wrappedValue))
```
Модификатор `SpoilerModifier` принимает `Bool`, но внутри `spoiler()` также добавляется `.onTapGesture` и `.opacity`, которые зависят от `Binding`. Это работает, но логика разбросана — часть в модификаторе, часть в расширении. Лучше инкапсулировать всё в одном `ViewModifier`.

### 3. Нет `accessibilityLabel` для скрытого контента
Когда баланс скрыт спойлером, VoiceOver всё равно может прочитать его. Стоит добавить accessibility-модификатор.
