// file: MyEventsListRow.swift

import SwiftUI

// Убираем .viewDetails
enum EventAction {
    case delete
    case leave
}

struct MyEventsListRow: View {
    @EnvironmentObject var authManager: AuthManager
    let event: Event
    let onAction: (EventAction) -> Void
    
    var body: some View {
        NavigationLink(value: event) {
            EventRowView(event: event)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
        .padding(.vertical, 4)
        .listRowSeparator(.hidden)
        .contextMenu {
            // Убрали кнопку "Детали ивента"
            if let currentUserId = authManager.user?.uid {
                if currentUserId == event.creatorId {
                    Button(role: .destructive) {
                        onAction(.delete)
                    } label: {
                        Label("Удалить ивент", systemImage: "trash")
                    }
                } else {
                    Button(role: .destructive) {
                        onAction(.leave)
                    } label: {
                        Label("Покинуть ивент", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
}
