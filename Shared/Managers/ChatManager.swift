import Foundation
import FirebaseFirestore

final class ChatManager {
    
    static let shared = ChatManager()
    private init() {}
    
    // Хелпер, который возвращает путь к подколлекции 'messages' для конкретного ивента
    private func eventMessagesCollection(eventId: String) -> CollectionReference {
        Firestore.firestore(database: "partyapp")
            .collection("events")
            .document(eventId)
            .collection("messages")
    }
    
    /// Отправляет новое сообщение в чат ивента.
    func sendMessage(text: String, eventId: String, sender: DBUser) async throws {
        // ИСПРАВЛЕНИЕ: Используем 'id', который мы определили для протокола Identifiable.
        // Так как он не опциональный, 'guard let' не нужен.
        let senderId = sender.id
        
        let message = ChatMessage(
            eventId: eventId,
            senderId: senderId,
            text: text,
            timestamp: Date(),
            senderName: sender.name,
            senderAvatarURL: sender.profileImageURL
        )
        
        try await eventMessagesCollection(eventId: eventId).addDocument(from: message)
    }
    
    /// Начинает прослушивание сообщений для конкретного ивента в реальном времени.
    /// Возвращает 'поток' (AsyncStream) сообщений.
    func listenForMessages(eventId: String) -> AsyncStream<[ChatMessage]> {
        // AsyncStream - это современный способ работы с данными, которые приходят со временем.
        return AsyncStream { continuation in
            // Создаем "слушателя", который будет срабатывать при любом изменении в коллекции сообщений
            let listener = eventMessagesCollection(eventId: eventId)
                .order(by: "timestamp", descending: false) // Сортируем по времени
                .addSnapshotListener { querySnapshot, error in
                    
                    guard let snapshot = querySnapshot else {
                        print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // Декодируем все документы в массив объектов ChatMessage
                    let messages = snapshot.documents.compactMap { document in
                        try? document.data(as: ChatMessage.self)
                    }
                    
                    // Отправляем новый массив сообщений в наш "поток"
                    continuation.yield(messages)
                }
            
            // Этот блок выполнится, когда мы перестанем "слушать" поток
            continuation.onTermination = { @Sendable _ in
                // Отключаем "слушателя", чтобы не тратить ресурсы
                listener.remove()
                print("Message listener removed for event \(eventId)")
            }
        }
    }
}
