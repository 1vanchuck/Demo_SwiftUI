import SwiftUI

// Определяем возможные действия, которые может совершить пользователь
enum EventAction {
    case delete
    case leave
}

struct MyEventsListRow: View {
    // Получаем AuthManager для проверки, кто является создателем
    @EnvironmentObject var authManager: AuthManager
    
    // Ивент, который отображает эта строка
    let event: Event
    // Замыкание (closure), которое "сообщает" родителю о действии
    let onAction: (EventAction) -> Void
    
    var body: some View {
        ZStack {
            EventRowView(event: event)
            
            // Невидимая навигационная ссылка
            NavigationLink(destination: EventDetailView(event: event)) {
                EmptyView()
            }
            .opacity(0)
        }
        .listRowInsets(EdgeInsets())
        .padding(.vertical, 6)
        .listRowSeparator(.hidden)
        // Контекстное меню теперь просто вызывает замыкание onAction
        .contextMenu {
            if let currentUserId = authManager.user?.uid {
                if currentUserId == event.creatorId {
                    Button(role: .destructive) {
                        onAction(.delete) // Сообщаем, что нужно удалить
                    } label: {
                        Label("Удалить ивент", systemImage: "trash")
                    }
                } else {
                    Button(role: .destructive) {
                        onAction(.leave) // Сообщаем, что нужно выйти
                    } label: {
                        Label("Покинуть ивент", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
}
