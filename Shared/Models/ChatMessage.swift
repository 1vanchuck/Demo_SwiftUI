import Foundation
import FirebaseFirestore

struct ChatMessage: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    
    let eventId: String
    let senderId: String
    let text: String
    let timestamp: Date
    
    // These fields are denormalized for convenience. They store a snapshot
    // of the sender's data at the time the message was sent, avoiding extra lookups.
    var senderName: String?
    var senderAvatarURL: String?
}
