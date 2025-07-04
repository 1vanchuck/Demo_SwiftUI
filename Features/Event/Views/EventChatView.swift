import SwiftUI

struct EventChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @EnvironmentObject var authManager: AuthManager
    
    @State private var currentUserProfile: DBUser?
    @State private var showEventDetail = false

    init(event: Event) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(event: event))
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                    scrollToBottom(proxy: proxy)
                }
            }
            
            messageInputBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showEventDetail) {
            EventDetailView(event: viewModel.event)
        }
        .onAppear {
            viewModel.startListeningForMessages()
            Task {
                // We need the full user profile to send messages with sender details.
                guard let currentUserId = authManager.user?.uid else { return }
                self.currentUserProfile = try? await UserManager.shared.getUser(userId: currentUserId)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                // The toolbar title is a button that leads to the event details.
                Button(action: { self.showEventDetail = true }) {
                    VStack {
                        Text(viewModel.event.title)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text("\(viewModel.event.attendees.count) members")
                            .font(.caption2)
                    }
                    .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { self.showEventDetail = true }) {
                    AsyncImage(url: URL(string: viewModel.event.imageURL ?? "")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 36)
                    .clipShape(Circle())
                }
            }
        }
    }
    
    private var messageInputBar: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Message...", text: $viewModel.messageText, axis: .vertical)
                .lineLimit(1...14)
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                )

            Button {
                sendMessage()
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
    
    private func sendMessage() {
        guard !viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let userProfile = currentUserProfile else { return }
        Task {
            await viewModel.sendMessage(sender: userProfile)
        }
    }
    
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
#Preview {
    NavigationStack {
        let previewEvent = Event(
            title: "Beach Party",
            eventDate: Date(),
            locationName: "Cascais",
            creatorId: "user123"
        )
        
        let authManager = AuthManager()
        
        EventChatView(event: previewEvent)
            .environmentObject(authManager)
    }
}
