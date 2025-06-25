// file: MyEventsView.swift

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
                        // Для каждой строки в списке мы передаем замыкание onAction
                        ForEach(viewModel.myEvents) { event in
                            MyEventsListRow(event: event) { action in
                                // Вся логика обработки нажатий теперь здесь
                                handle(action: action, for: event)
                            }
                        }
                    }
                    .listStyle(.plain)
                    // Основной маршрут навигации из списка теперь ведет напрямую в чат
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
    
    // Вспомогательная функция для обработки действий из контекстного меню
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
    // Для превью нужно предоставить окружение
    let authManager = AuthManager()
    let eventsViewModel = EventsViewModel()
    
    // Можно добавить фейковый ивент для отображения в превью
    // let previewEvent = Event(title: "Preview Event", eventDate: Date(), locationName: "SwiftUI", creatorId: "previewUser")
    // eventsViewModel.myEvents = [previewEvent]
    
    return MyEventsView()
        .environmentObject(authManager)
        .environmentObject(eventsViewModel)
}
