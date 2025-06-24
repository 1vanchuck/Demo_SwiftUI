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
    
    // Эта функция будет вызываться из View при его появлении
    func onAppear(currentUserId: String?) {
        updateRsvpStatus(for: currentUserId)
        
        // Подписываемся на изменения в ивенте, чтобы UI обновлялся
        // когда кто-то присоединяется или покидает его.
        $event
            .sink { [weak self] updatedEvent in
                self?.updateRsvpStatus(for: currentUserId)
            }
            .store(in: &cancellables)
            
        Task {
            await fetchAttendees()
        }
    }
    
    // Проверяем статус текущего пользователя
    private func updateRsvpStatus(for currentUserId: String?) {
        guard let currentUserId = currentUserId else { return }
        self.currentUserRsvpStatus = event.attendees[currentUserId]
    }
    
    // Загружаем профили участников
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
    
    // Присоединиться к ивенту
    func joinEvent(currentUserId: String) async {
        isLoading = true
        do {
            try await EventManager.shared.joinEvent(event: event, userId: currentUserId)
            // Обновляем локальные данные после успешной операции
            event.attendees[currentUserId] = .going
        } catch { print("Error joining event: \(error.localizedDescription)") }
        isLoading = false
    }
    
    // Покинуть ивент
    func leaveEvent(currentUserId: String) async {
        isLoading = true
        do {
            try await EventManager.shared.leaveEvent(event: event, userId: currentUserId)
            // Обновляем локальные данные
            event.attendees.removeValue(forKey: currentUserId)
        } catch { print("Error leaving event: \(error.localizedDescription)") }
        isLoading = false
    }
}
