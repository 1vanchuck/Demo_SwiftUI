import SwiftUI

struct MyEventsView: View {
    @EnvironmentObject var viewModel: EventsViewModel
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading && viewModel.myEvents.isEmpty {
                    ProgressView()
                } else if viewModel.myEvents.isEmpty {
                    // Empty state view to guide the user.
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("You have no events yet")
                            .font(.headline)
                        Text("Go to the '+' tab to create your first event.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        // The onAction closure passes the user's choice from the context menu
                        // back to this view for handling.
                        ForEach(viewModel.myEvents) { event in
                            MyEventsListRow(event: event) { action in
                                handle(action: action, for: event)
                            }
                        }
                    }
                    .listStyle(.plain)
                    // The primary navigation destination from the list is now the event chat.
                    .navigationDestination(for: Event.self) { event in
                        EventChatView(event: event)
                    }
                    .refreshable {
                        if let userId = authManager.user?.uid {
                            await viewModel.fetchMyEvents(for: userId)
                        }
                    }
                }
            }
            .navigationTitle("My Events")
            .onAppear {
                if let userId = authManager.user?.uid, viewModel.myEvents.isEmpty {
                    Task {
                        await viewModel.fetchMyEvents(for: userId)
                    }
                }
            }
        }
    }
    
    /// A helper function to process actions from the context menu.
    private func handle(action: EventAction, for event: Event) {
        switch action {
        case .delete:
            Task {
                await viewModel.deleteEvent(event: event)
            }
        case .leave:
            guard let userId = authManager.user?.uid else { return }
            Task {
                await viewModel.leaveEvent(event: event, userId: userId)
            }
        }
    }
}

#Preview {
    let authManager = AuthManager()
    let eventsViewModel = EventsViewModel()
    
    // For a more realistic preview, you could inject a dummy event.
    // let previewEvent = Event(title: "Preview Event", eventDate: Date(), locationName: "SwiftUI", creatorId: "previewUser")
    // eventsViewModel.myEvents = [previewEvent]
    
    return MyEventsView()
        .environmentObject(authManager)
        .environmentObject(eventsViewModel)
}
