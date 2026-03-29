# StatItem.swift — Code Review

## Замечания

### 1. `amount: Decimal` без кастомного `Codable`
Как и в других DTO, если сервер шлёт `amount` как строку, стандартный декодер упадёт. Впрочем, `StatItem` используется только в `AccountResponse`, который сам не используется — так что это мёртвый код.

### 2. `emoji: String` vs `Category.emoji: Character`
В `Category` emoji хранится как `Character`, а в `StatItem` — как `String`. Нет единообразия в представлении одних и тех же данных.
