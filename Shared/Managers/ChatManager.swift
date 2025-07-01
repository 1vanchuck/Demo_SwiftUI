import Foundation
import FirebaseFirestore

final class ChatManager {
    
    static let shared = ChatManager()
    private init() {}
    
    /// A helper function to get a reference to the 'messages' subcollection for a specific event.
    private func eventMessagesCollection(eventId: String) -> CollectionReference {
        Firestore.firestore(database: "partyapp")
            .collection("events")
            .document(eventId)
            .collection("messages")
    }
    
    /// Sends a new message to an event's chat.
    func sendMessage(text: String, eventId: String, sender: DBUser) async throws {
        // We can safely use the non-optional `id` property from our Identifiable DBUser.
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
    
    /// Listens for real-time message updates for a specific event.
    /// - Returns: An `AsyncStream` of message arrays.
    func listenForMessages(eventId: String) -> AsyncStream<[ChatMessage]> {
        return AsyncStream { continuation in
            // Set up a snapshot listener to receive updates whenever the messages collection changes.
            let listener = eventMessagesCollection(eventId: eventId)
                .order(by: "timestamp", descending: false) // Sort messages chronologically.
                .addSnapshotListener { querySnapshot, error in
                    
                    guard let snapshot = querySnapshot else {
                        print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // Decode all documents into an array of ChatMessage objects.
                    let messages = snapshot.documents.compactMap { document in
                        try? document.data(as: ChatMessage.self)
                    }
                    
                    // Yield the new array to the stream.
                    continuation.yield(messages)
                }
            
            // This closure is called when the stream is terminated.
            continuation.onTermination = { @Sendable _ in
                // It's crucial to remove the listener to prevent resource leaks.
                listener.remove()
                print("Message listener removed for event \(eventId)")
            }
        }
    }
}
