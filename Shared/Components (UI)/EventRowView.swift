import SwiftUI

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 16) {
            // Картинка ивента
            AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                // Заглушка, если картинки нет
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .frame(width: 60, height: 60)
                    .background(Color.secondary.opacity(0.2))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            // Текстовая информация
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                // TODO: В будущем здесь можно будет определять,
                // вы создатель ("Hosting") или участник ("Going")
                Text("You • Hosting")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer() // Отодвигает кнопку "..." вправо
            
            // Кнопка "больше опций"
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    // Для превью создаем фейковый ивент
    let previewEvent = Event(title: "Untitled Event",
                             eventDate: Date(),
                             locationName: "Someplace",
                             creatorId: "123")
    
    return EventRowView(event: previewEvent)
        .padding()
}
