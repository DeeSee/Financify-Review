/// ## Ревью: `Financify/Utils/Errors.swift`
/// 
/// ## Важно
/// - **Нейминг**:
///   - `BankAccountServicesError` лучше назвать `BankAccountServiceError` (singular), чтобы совпадало с названием сервиса.
/// - **Ошибки как `case ... (String)`**:
///   - Это удобно, но обычно лучше сделать `LocalizedError` и формировать `errorDescription`, чтобы UI мог единообразно показывать сообщения.
/// 
/// ## Нюансы
/// - В одном файле лежат ошибки разных подсистем (`BankAccount...`, `TransactionsFileCache...`). Это не проблема, но часто удобнее держать ближе к месту использования (или хотя бы группировать по папкам/модулям).
/// 

enum BankAccountServicesError: Error {
    case accountNotExists(String)
}

enum TransactionsFileCacheError: Error {
    case transactionAlreadyExists(String)
    case transactionNotExists(String)
    case fileNotExists(String)
    case wrongFormat(String)
}
