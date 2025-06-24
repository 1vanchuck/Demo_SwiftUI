import SwiftUI
import MapKit

struct LocationPickerView: View {
    let onLocationSelect: (CLLocationCoordinate2D) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.36, longitude: 4.90),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var hasCenteredOnUser = false

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                .ignoresSafeArea()
                .onAppear {
                    locationManager.requestLocationPermission()
                }
                .onChange(of: locationManager.location) { _, newLocation in
                    if let newLocation, !hasCenteredOnUser {
                        region.center = newLocation.coordinate
                        hasCenteredOnUser = true
                    }
                }

            Image(systemName: "mappin").font(.largeTitle).foregroundColor(.red)
            
            // Контейнер для кнопок
            VStack(spacing: 15) {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        // НОВАЯ КНОПКА
                        Button(action: {
                            if let userLocation = locationManager.location {
                                withAnimation {
                                    region.center = userLocation.coordinate
                                }
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.headline).padding(10)
                        }
                        
                        // Старые кнопки зума
                        Button(action: { zoom(factor: 0.5) }) { Image(systemName: "plus").font(.headline).padding(10) }
                        Button(action: { zoom(factor: 2.0) }) { Image(systemName: "minus").font(.headline).padding(10) }
                    }
                    .foregroundColor(.primary).background(.regularMaterial).cornerRadius(10).shadow(radius: 3)
                }
                .padding()

                Spacer()
                
                Button("Confirm Location") {
                    onLocationSelect(region.center)
                    dismiss()
                }
                .fontWeight(.semibold).frame(maxWidth: .infinity).padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
            .padding()
        }
    }
    
    private func zoom(factor: Double) {
        var newSpan = self.region.span
        newSpan.latitudeDelta *= factor
        newSpan.longitudeDelta *= factor
        self.region.span = newSpan
    }
}
