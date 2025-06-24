import SwiftUI
import UIKit // Импортируем UIKit для открытия настроек

// View для случая, когда доступ запрещен
struct LocationDeniedView: View {
    var body: some View {
        VStack(spacing: 15) {
            Spacer()

            Image(systemName: "location.slash.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.gray)
            
            Text("Доступ к геолокации запрещен")
                .font(.title2).bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Чтобы использовать функции карты, пожалуйста, включите доступ к геолокации для этого приложения в Настройках вашего iPhone.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            // Кнопка, которая открывает системные настройки приложения
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Button("Открыть Настройки") {
                    UIApplication.shared.open(url)
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.2))
                .foregroundStyle(.primary)
                .cornerRadius(15)
            }
        }
        .padding()
    }
}

#Preview {
    LocationDeniedView()
}
