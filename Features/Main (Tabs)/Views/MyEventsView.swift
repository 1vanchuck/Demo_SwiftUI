import SwiftUI

struct MyEventsView: View {
    // Получаем ViewModel и AuthManager из окружения
    @EnvironmentObject var viewModel: EventsViewModel
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading && viewModel.myEvents.isEmpty {
                    ProgressView()
                } else if viewModel.myEvents.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("У вас пока нет ивентов")
                            .font(.headline)
                        Text("Перейдите на вкладку '+' чтобы создать свой первый ивент.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        // ИЗМЕНЕНИЕ: Мы передаем замыкание onAction прямо здесь
                        ForEach(viewModel.myEvents) { event in
                            MyEventsListRow(event: event) { action in
                                // Вся логика обработки нажатий теперь здесь
                                handle(action: action, for: event)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        if let userId = authManager.user?.uid {
                            await viewModel.fetchMyEvents(for: userId)
                        }
                    }
                }
            }
            .navigationTitle("Мои ивенты")
            .onAppear {
                if let userId = authManager.user?.uid, viewModel.myEvents.isEmpty {
                    Task {
                        await viewModel.fetchMyEvents(for: userId)
                    }
                }
            }
        }
    }
    
    // Вспомогательная функция для обработки действий
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
    MyEventsView()
        .environmentObject(AuthManager())
        .environmentObject(EventsViewModel())
}
