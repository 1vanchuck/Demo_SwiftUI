import Foundation
import FirebaseFirestore

struct ChatMessage: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    
    let eventId: String // ID ивента, к которому относится сообщение
    let senderId: String // ID пользователя, отправившего сообщение
    let text: String
    let timestamp: Date
    
    // Дополнительные поля, которые нам пригодятся в будущем
    var senderName: String? // Можем хранить имя отправителя для удобства
    var senderAvatarURL: String?
}
