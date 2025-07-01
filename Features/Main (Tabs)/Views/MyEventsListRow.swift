import SwiftUI

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
            // The context menu provides different actions based on user ownership.
            if let currentUserId = authManager.user?.uid {
                if currentUserId == event.creatorId {
                    Button(role: .destructive) {
                        onAction(.delete)
                    } label: {
                        Label("Delete Event", systemImage: "trash")
                    }
                } else {
                    Button(role: .destructive) {
                        onAction(.leave)
                    } label: {
                        Label("Leave Event", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        MyEventsListRow(
            event: Event(
                title: "My Awesome Event",
                eventDate: Date(),
                locationName: "My House",
                creatorId: "user123"
            ),
            onAction: { action in
                print("Action selected: \(action)")
            }
        )
    }
    .environmentObject(AuthManager())
}

