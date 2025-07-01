import Foundation
import FirebaseFirestore

final class EventManager {
    
    static let shared = EventManager()
    private init() {}
    
    private let eventsCollection = Firestore.firestore(database: "partyapp").collection("events")
    
    private func eventDocument(eventId: String) -> DocumentReference {
        eventsCollection.document(eventId)
    }
    
    func createEvent(event: Event) async throws {
        guard let eventId = event.id else { throw URLError(.badURL) }
        try eventDocument(eventId: eventId).setData(from: event)
    }
    
    /// Adds the current user to an event's attendee list.
    func joinEvent(event: Event, userId: String) async throws {
        guard let eventId = event.id else { throw URLError(.badURL) }
        
        // Using 'updateData' to modify only a single field in the document.
        // Dot notation is used to add a new key to the 'attendees' map.
        let data: [String: Any] = [
            "attendees.\(userId)": RSVPStatus.going.rawValue
        ]
        try await eventDocument(eventId: eventId).updateData(data)
    }

    /// Removes the current user from an event's attendee list.
    func leaveEvent(event: Event, userId: String) async throws {
        guard let eventId = event.id else { throw URLError(.badURL) }
        
        // We use the special FieldValue.delete() to remove a key (the user's ID)
        // from the 'attendees' map.
        let data: [String: Any] = [
            "attendees.\(userId)": FieldValue.delete()
        ]
        try await eventDocument(eventId: eventId).updateData(data)
    }
    
    func fetchEvents(forUserID userId: String) async throws -> [Event] {
        // This query fetches all events where the user's ID exists as a key in the attendees map.
        let snapshot = try await eventsCollection
            .whereField("attendees.\(userId)", isNotEqualTo: NSNull())
            .getDocuments()
        return try snapshot.documents.compactMap { try? $0.data(as: Event.self) }
    }
    
    func fetchAllEvents() async throws -> [Event] {
        let snapshot = try await eventsCollection.getDocuments()
        return try snapshot.documents.compactMap { try? $0.data(as: Event.self) }
    }
    
    func deleteEvent(eventId: String) async throws {
        try await eventDocument(eventId: eventId).delete()
    }
}
