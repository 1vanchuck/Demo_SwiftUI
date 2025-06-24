import SwiftUI
import CoreLocation

// View для запроса разрешения
struct RequestLocationView: View {
    // Получаем locationManager для вызова функции запроса
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            
            Image(systemName: "location.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.purple.opacity(0.8))
            
            Text("Требуется доступ к геолокации")
                .font(.title2).bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Нам нужна ваша геолокация, чтобы показывать вас на карте и находить ивенты поблизости.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button("Разрешить доступ") {
                locationManager.requestLocationPermission()
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .padding()
    }
}

#Preview {
    RequestLocationView(locationManager: LocationManager())
}
