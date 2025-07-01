import Foundation
import Combine

@MainActor
class EventDetailViewModel: ObservableObject {
    
    @Published var event: Event
    @Published var attendees: [DBUser] = []
    @Published var currentUserRsvpStatus: RSVPStatus?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()

    init(event: Event) {
        self.event = event
    }
    
    func onAppear(currentUserId: String?) {
        updateRsvpStatus(for: currentUserId)
        
        $event
            .sink { [weak self] updatedEvent in
                self?.updateRsvpStatus(for: currentUserId)
            }
            .store(in: &cancellables)
            
        Task {
            await fetchAttendees()
        }
    }
    
    private func updateRsvpStatus(for currentUserId: String?) {
        guard let currentUserId = currentUserId else { return }
        self.currentUserRsvpStatus = event.attendees[currentUserId]
    }
    
    func fetchAttendees() async {
        let userIds = Array(event.attendees.keys)
        guard !userIds.isEmpty else {
            self.attendees = []
            return
        }
        
        do {
            self.attendees = try await UserManager.shared.fetchUsers(withIDs: userIds)
        } catch {
            print("Error fetching attendees: \(error.localizedDescription)")
        }
    }
    
    func joinEvent(currentUserId: String) async {
        isLoading = true
        do {
            try await EventManager.shared.joinEvent(event: event, userId: currentUserId)
            event.attendees[currentUserId] = .going
        } catch { print("Error joining event: \(error.localizedDescription)") }
        isLoading = false
    }
    
    func leaveEvent(currentUserId: String) async {
        isLoading = true
        do {
            try await EventManager.shared.leaveEvent(event: event, userId: currentUserId)
            event.attendees.removeValue(forKey: currentUserId)
        } catch { print("Error leaving event: \(error.localizedDescription)") }
        isLoading = false
    }
}
