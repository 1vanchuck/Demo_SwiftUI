// file: EventRowView.swift

import SwiftUI

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            // ИЗМЕНЕНИЕ: Аватар ивента теперь круглый
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
            .clipShape(Circle()) // Делаем аватар круглым
            
            // ИЗМЕНЕНИЕ: Текст теперь в две строки
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                // Заглушка для последнего сообщения
                Text("Last message placeholder...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1) // Ограничиваем одной строкой
            }
            
            Spacer() // Отодвигает блок времени вправо
            
            // ИЗМЕНЕНИЕ: Добавляем блок времени
            VStack(alignment: .trailing, spacing: 4) {
                // Заглушка для времени
                Text("22:31")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Здесь будет заглушка для счетчика непрочитанных
                // Можно пока оставить пустым или добавить статический бейдж для вида
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        // Убираем фон и скругление, т.к. этим будет управлять List
    }
}
