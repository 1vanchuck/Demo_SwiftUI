import SwiftUI

struct EventDetailView: View {
    // Создаем ViewModel при инициализации этого View, передавая ему конкретный ивент
    @StateObject private var viewModel: EventDetailViewModel
    // Получаем AuthManager из окружения для доступа к ID текущего пользователя
    @EnvironmentObject var authManager: AuthManager

    init(event: Event) {
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 1. Обложка ивента
                AsyncImage(url: URL(string: viewModel.event.imageURL ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.secondary.opacity(0.3))
                }
                .frame(height: 300)
                
                // 2. Блок с основной информацией
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.event.title)
                        .font(.largeTitle).bold()
                    
                    InfoRow(iconName: "calendar", text: viewModel.event.eventDate.formatted(.dateTime.day().month().year().hour().minute()))
                    InfoRow(iconName: "mappin.and.ellipse", text: viewModel.event.locationName)
                    
                    if let description = viewModel.event.descriptionText, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .padding(.top, 8)
                    }
                }
                .padding()
                
                Divider()
                
                // 3. Блок с участниками
                VStack(alignment: .leading) {
                    Text("Who's going (\(viewModel.attendees.count))")
                        .font(.headline).padding([.top, .horizontal])
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -10) {
                            // ИСПРАВЛЕНИЕ: Используем 'id: \.userId', чтобы ForEach работал
                            ForEach(viewModel.attendees, id: \.userId) { user in
                                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill").font(.title).foregroundColor(.secondary)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            // 4. Кнопка для присоединения/выхода
            if let userId = authManager.user?.uid {
                // Не показываем кнопку создателю ивента
                if viewModel.event.creatorId != userId {
                    rsvpButton(currentUserId: userId)
                        .padding()
                        .background(.thinMaterial)
                }
            }
        }
        .onAppear {
            // Передаем ID пользователя при появлении экрана
            viewModel.onAppear(currentUserId: authManager.user?.uid)
        }
        .navigationTitle(viewModel.event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // Кнопка-ссылка на экран чата
                NavigationLink(destination: EventChatView(event: viewModel.event)) {
                    Image(systemName: "message.fill")
                }
            }
        }
    }
    
    // Вспомогательная функция для кнопки RSVP, вынесена из body
    @ViewBuilder
    private func rsvpButton(currentUserId: String) -> some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
        } else {
            switch viewModel.currentUserRsvpStatus {
            case .going:
                Button("You are going • Leave event", role: .destructive) {
                    Task { await viewModel.leaveEvent(currentUserId: currentUserId) }
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .gray))
                
            case .none, .pending, .cantGo, .maybe:
                Button("Join Event") {
                    Task { await viewModel.joinEvent(currentUserId: currentUserId) }
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .purple))
            }
        }
    }
}
