import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var messageText: String = ""
    
    // Этот объект больше не будет меняться, поэтому делаем его let
    let event: Event
    
    private var messagesListenerTask: Task<Void, Error>?
    
    // MARK: - Initializer & Deinitializer
    
    init(event: Event) {
        self.event = event
    }
    
    deinit {
        // Отменяем задачу, когда View уничтожается
        messagesListenerTask?.cancel()
        print("ChatViewModel deinitialized and listener task cancelled.")
    }
    
    // MARK: - Public Methods
    
    /// Начинает прослушивание сообщений. Вызывается из View.
    func startListeningForMessages() {
        // Проверяем, что у ивента есть ID
        guard let eventId = event.id else {
            print("Error: Event ID is nil, cannot listen for messages.")
            return
        }
        
        // Отменяем предыдущего слушателя, если он был
        messagesListenerTask?.cancel()
        
        // Запускаем новую задачу в фоне
        messagesListenerTask = Task {
            for try await updatedMessages in ChatManager.shared.listenForMessages(eventId: eventId) {
                // Каждый раз, когда приходят новые данные, обновляем наш массив
                self.messages = updatedMessages
            }
        }
    }
    
    /// Отправляет сообщение от текущего пользователя
    func sendMessage(sender: DBUser) async {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty, let eventId = event.id else { return }
        
        let textToSend = messageText
        self.messageText = "" // Сбрасываем поле ввода сразу
        
        do {
            try await ChatManager.shared.sendMessage(
                text: textToSend,
                eventId: eventId,
                sender: sender
            )
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            // Возвращаем текст обратно, если отправка не удалась
            self.messageText = textToSend
        }
    }
}
