/// ## Ревью: `Financify/Domain/EmptyRequest.swift`
/// 
/// ## Нюансы
/// - `EmptyRequest` используется как “маркер” для перегрузок `NetworkClient` без тела запроса. Это ок.
/// - Структура пустая, но `Codable` — тоже ок (тип действительно кодируется в пустой объект).
/// 

struct EmptyRequest: Codable { }
