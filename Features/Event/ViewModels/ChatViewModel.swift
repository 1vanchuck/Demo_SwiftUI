import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    
    @Published var messages: [ChatMessage] = []
    @Published var messageText: String = ""
    
    // The event is a constant for this ViewModel's lifecycle.
    let event: Event
    
    private var messagesListenerTask: Task<Void, Error>?
    
    init(event: Event) {
        self.event = event
    }
    
    deinit {
        // It's crucial to cancel the listening task when the view is dismissed
        // to prevent memory leaks and unnecessary background work.
        messagesListenerTask?.cancel()
        print("ChatViewModel deinitialized and listener task cancelled.")
    }
    
    /// Starts listening for real-time message updates from Firestore.
    /// This should be called when the view appears.
    func startListeningForMessages() {
        guard let eventId = event.id else {
            print("Error: Event ID is nil, cannot listen for messages.")
            return
        }
        
        // Cancel any previous listener before starting a new one.
        messagesListenerTask?.cancel()
        
        messagesListenerTask = Task {
            for try await updatedMessages in ChatManager.shared.listenForMessages(eventId: eventId) {
                // The UI will automatically update whenever the `messages` array changes.
                self.messages = updatedMessages
            }
        }
    }
    
    /// Sends a new message from the current user.
    func sendMessage(sender: DBUser) async {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty, let eventId = event.id else { return }
        
        let textToSend = messageText
        self.messageText = "" // Clear the input field immediately for a better UX.
        
        do {
            try await ChatManager.shared.sendMessage(
                text: textToSend,
                eventId: eventId,
                sender: sender
            )
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            // If sending fails, restore the text so the user can try again.
            self.messageText = textToSend
        }
    }
}
