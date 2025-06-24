import SwiftUI

struct ChatMessageRow: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            // Если сообщение от текущего пользователя, отодвигаем его вправо
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Если сообщение не от текущего пользователя, показываем его имя
                if !isFromCurrentUser {
                    Text(message.senderName ?? "Unknown")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Text(message.text)
                
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundColor(isFromCurrentUser ? .white.opacity(0.7) : .secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isFromCurrentUser ? .purple : Color(.secondarySystemBackground))
            .foregroundColor(isFromCurrentUser ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(maxWidth: 300, alignment: isFromCurrentUser ? .trailing : .leading) // Ограничиваем ширину
            
            // Если сообщение не от текущего пользователя, отодвигаем его влево
            if !isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
