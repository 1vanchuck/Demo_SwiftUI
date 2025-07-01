import SwiftUI
import CoreLocation

/// A view to request location permission from the user.
struct RequestLocationView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            
            Image(systemName: "location.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.purple.opacity(0.8))
            
            Text("Location Access Required")
                .font(.title2).bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("We need your location to show you on the map and help you find nearby events.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button("Allow Access") {
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
