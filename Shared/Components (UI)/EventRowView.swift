import SwiftUI

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            // The event avatar is now circular for a cleaner list view.
            AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .frame(width: 55, height: 55)
                    .background(Color.secondary.opacity(0.2))
            }
            .frame(width: 55, height: 55)
            .clipShape(Circle())
            
            // The main text is now structured in two lines for better readability.
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                // This could be updated with the actual last message from the chat.
                Text("Last message placeholder...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Placeholder for the timestamp of the last message.
                Text("10:31 PM")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // An unread message indicator could be added here.
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
