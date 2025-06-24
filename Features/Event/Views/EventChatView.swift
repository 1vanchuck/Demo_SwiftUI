import SwiftUI

struct EventChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @EnvironmentObject var authManager: AuthManager
    
    // Храним профиль текущего пользователя для отправки сообщений
    @State private var currentUserProfile: DBUser?

    init(event: Event) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(event: event))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Список сообщений с автопрокруткой
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        ForEach(viewModel.messages) { message in
                            ChatMessageRow(
                                message: message,
                                isFromCurrentUser: message.senderId == authManager.user?.uid
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.messages.count) {
                    // При изменении количества сообщений плавно прокручиваем вниз
                    scrollToBottom(proxy: proxy)
                }
            }
            
            // 2. Поле для ввода сообщения
            messageInputBar
        }
        .navigationTitle(viewModel.event.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // При появлении экрана запускаем прослушивание сообщений
            viewModel.startListeningForMessages()
            // И загружаем профиль текущего пользователя
            Task {
                guard let currentUserId = authManager.user?.uid else { return }
                self.currentUserProfile = try? await UserManager.shared.getUser(userId: currentUserId)
            }
        }
        .toolbar {
            // Кнопка для перехода на экран деталей группы
            ToolbarItem(placement: .principal) {
                Button(action: {
                    // TODO: Реализовать переход на экран деталей
                    print("Navigate to group details")
                }) {
                    VStack {
                        Text(viewModel.event.title).fontWeight(.semibold)
                        Text("\(viewModel.event.attendees.count) members").font(.caption2)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    // UI для поля ввода и кнопки отправки
    private var messageInputBar: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextEditor(text: $viewModel.messageText)
                .font(.subheadline)
                .frame(minHeight: 30, maxHeight: 120)
                .padding(4)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                )

            Button {
                guard let userProfile = currentUserProfile else { return }
                Task {
                    await viewModel.sendMessage(sender: userProfile)
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.body.weight(.semibold))
                    .padding(10)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .disabled(viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .background(.thinMaterial)
    }
    
    // Функция для автоматической прокрутки к последнему сообщению
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        guard let lastMessageId = viewModel.messages.last?.id else { return }
        if animated {
            withAnimation {
                proxy.scrollTo(lastMessageId, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(lastMessageId, anchor: .bottom)
        }
    }
}
