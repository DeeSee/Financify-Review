/// ## Ревью: `Financify/Persistence/PersistentTransaction.swift`
/// 
/// ## Важно
/// - **Soft-delete флаг `isPendingDeletion`** выглядит логичным для офлайн удаления. При этом важно, чтобы все запросы к базе (для UI) consistently исключали такие записи — сейчас это делается точечно.
/// - **`id: Int` как уникальный ключ**:
///   - Для офлайн-создания используются отрицательные id — ок как приём, но важно избегать коллизий (см. `TransactionsService.saveToAdd`).
/// 
/// ## Нюансы
/// - Стоит подумать о **индексации/оптимизации выборок** (если объём транзакций вырастет): сейчас часто делаются full fetch + фильтрация на клиенте.
/// 
/// ## Предложения
/// - Централизовать “правильный” `FetchDescriptor` для отображаемых транзакций (например, helper), чтобы не забывать `isPendingDeletion == false`.
/// 

import Foundation
import SwiftData

@Model
final class PersistentTransaction {
    @Attribute(.unique)
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
    
    var isPendingDeletion: Bool = false
    
    init(
        id: Int,
        accountId: Int,
        categoryId: Int,
        amount: Decimal,
        transactionDate: Date,
        comment: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPendingDeletion = false
    }
    
    convenience init(from domain: Transaction) {
        self.init(
            id: domain.id,
            accountId: domain.accountId,
            categoryId: domain.categoryId,
            amount: domain.amount,
            transactionDate: domain.transactionDate,
            comment: domain.comment,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
    
    func toDomain() -> Transaction {
        Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
