# LoadingAnimation.swift — Code Review

## Замечания

### 1. `CircleInside` и `CircleOutside` — публичные структуры (строки 31, 41)
```swift
struct CircleInside: View { ... }
struct CircleOutside: View { ... }
```
Эти вспомогательные view не должны быть доступны за пределами файла. Стоит пометить `private` или `fileprivate`.

### 2. Анимация запускается в `onAppear` — нет остановки
```swift
.onAppear() {
    withAnimation(...repeatForever...) {
        start = true
    }
}
```
Анимация `repeatForever` будет продолжаться даже после удаления view из иерархии (до сборки мусора). Нет `onDisappear` для остановки.

### 3. `Text(verbatim: .loadingText)` — статическая русская строка
«Загрузка...» захардкожена без локализации.
