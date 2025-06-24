import Foundation
import FirebaseFirestore

final class EventManager {
    
    static let shared = EventManager()
    private init() {}
    
    private let eventsCollection = Firestore.firestore(database: "partyapp").collection("events")
    
    private func eventDocument(eventId: String) -> DocumentReference {
        eventsCollection.document(eventId)
    }
    
    // Функция для создания ивента (без изменений)
    func createEvent(event: Event) async throws {
        guard let eventId = event.id else { throw URLError(.badURL) }
        try eventDocument(eventId: eventId).setData(from: event)
    }
    
    // НОВАЯ ФУНКЦИЯ: Присоединение к ивенту
    func joinEvent(event: Event, userId: String) async throws {
        guard let eventId = event.id else { throw URLError(.badURL) }
        
        // Мы используем 'updateData' для изменения только одного поля в документе.
        // Используем "точечную нотацию" для добавления нового ключа в карту (словарь) attendees.
        let data: [String: Any] = [
            "attendees.\(userId)": RSVPStatus.going.rawValue
        ]
        try await eventDocument(eventId: eventId).updateData(data)
    }
    
    // Внутри класса EventManager

    // НОВАЯ ФУНКЦИЯ: Покинуть ивент
    func leaveEvent(event: Event, userId: String) async throws {
        guard let eventId = event.id else { throw URLError(.badURL) }
        
        // Мы используем специальное значение FieldValue.delete(),
        // чтобы удалить ключ (ID пользователя) из карты (словаря) attendees.
        let data: [String: Any] = [
            "attendees.\(userId)": FieldValue.delete()
        ]
        try await eventDocument(eventId: eventId).updateData(data)
    }
    
    // Функция для получения ивентов пользователя (без изменений)
    func fetchEvents(forUserID userId: String) async throws -> [Event] {
        let snapshot = try await eventsCollection
            .whereField("attendees.\(userId)", isNotEqualTo: NSNull())
            .getDocuments()
        return try snapshot.documents.compactMap { try? $0.data(as: Event.self) }
    }
    
    // Функция для получения всех ивентов (без изменений)
    func fetchAllEvents() async throws -> [Event] {
        let snapshot = try await eventsCollection.getDocuments()
        return try snapshot.documents.compactMap { try? $0.data(as: Event.self) }
        
    }
    
    func deleteEvent(eventId: String) async throws {
        try await eventDocument(eventId: eventId).delete()
    }
}
