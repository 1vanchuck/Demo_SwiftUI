import Foundation
import UIKit
import FirebaseFirestore
import MapKit

@MainActor
class EventsViewModel: ObservableObject {
    
    @Published var myEvents: [Event] = []
    @Published var allEvents: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didCreateEvent = false
    
    var eventsWithCoordinates: [Event] {
        allEvents.filter { $0.coordinates != nil }
    }
    
    func fetchMyEvents(for userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            self.myEvents = try await EventManager.shared.fetchEvents(forUserID: userId)
        } catch {
            errorMessage = "Failed to fetch events: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func fetchAllEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            self.allEvents = try await EventManager.shared.fetchAllEvents()
        } catch {
            errorMessage = "Failed to fetch all events: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func createEvent(title: String, eventDate: Date, locationName: String, coordinates: GeoPoint?, description: String?, image: UIImage?, creatorId: String, participantLimit: Int?) async {
        isLoading = true
        errorMessage = nil
        didCreateEvent = false
        
        var newEvent = Event(title: title, eventDate: eventDate, locationName: locationName, creatorId: creatorId)
        newEvent.id = UUID().uuidString
        newEvent.descriptionText = description
        newEvent.coordinates = coordinates
        newEvent.participantLimit = participantLimit // Сохраняем лимит
        
        do {
            if let image = image, let eventId = newEvent.id {
                let imageURL = try await StorageManager.shared.uploadEventImage(image: image, eventId: eventId)
                newEvent.imageURL = imageURL.absoluteString
            }
            try await EventManager.shared.createEvent(event: newEvent)
            didCreateEvent = true
        } catch {
            errorMessage = "Failed to create event: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func leaveEvent(event: Event, userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await EventManager.shared.leaveEvent(event: event, userId: userId)
            myEvents.removeAll { $0.id == event.id }
        } catch {
            errorMessage = "Failed to leave event: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func deleteEvent(event: Event) async {
        isLoading = true
        errorMessage = nil
        do {
            if event.imageURL != nil, let eventId = event.id {
                try await StorageManager.shared.deleteEventImage(eventId: eventId)
            }
            try await EventManager.shared.deleteEvent(eventId: event.id!)
            myEvents.removeAll { $0.id == event.id }
        } catch {
            errorMessage = "Failed to delete event: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
