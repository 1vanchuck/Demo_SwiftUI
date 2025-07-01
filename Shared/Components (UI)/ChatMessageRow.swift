import SwiftUI

struct ChatMessageRow: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if !isFromCurrentUser {
                    Text(message.senderName ?? "Unknown")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Text(message.text)
                
                // Grouping the timestamp and read receipt checkmark.
                HStack(spacing: 8) {
                    Spacer()
                    Text(message.timestamp.formatted(.dateTime.hour().minute()))
                        .font(.caption2)
                        .foregroundColor(isFromCurrentUser ? .white.opacity(0.7) : .secondary)
                    
                    if isFromCurrentUser {
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isFromCurrentUser ? .purple : Color(.secondarySystemBackground))
            .foregroundColor(isFromCurrentUser ? .white : .primary)
            // Using a continuous corner radius for a softer, more "bubbly" look.
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(maxWidth: 300, alignment: isFromCurrentUser ? .trailing : .leading)
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
