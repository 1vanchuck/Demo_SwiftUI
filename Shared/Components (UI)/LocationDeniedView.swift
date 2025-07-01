import SwiftUI
import UIKit

/// A view shown when location access has been denied by the user.
struct LocationDeniedView: View {
    var body: some View {
        VStack(spacing: 15) {
            Spacer()

            Image(systemName: "location.slash.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.gray)
            
            Text("Location Access Denied")
                .font(.title2).bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("To use map features, please enable location access for this app in your iPhone's Settings.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            // This button opens the app's specific page in the system Settings.
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Button("Open Settings") {
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
