import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = EventsViewModel()
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.0, longitude: 15.0),
        span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25)
    )
    @State private var hasCenteredOnUser = false
    @State private var selectedEvent: Event?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: viewModel.eventsWithCoordinates) { event in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: event.coordinates!.latitude,
                    longitude: event.coordinates!.longitude
                )) {
                    // UI для метки
                    Image(systemName: "party.popper.fill")
                        .padding(8)
                        .background(Color.purple.opacity(0.8))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                        .onTapGesture {
                            self.selectedEvent = event
                        }
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                locationManager.requestLocationPermission()
                Task {
                    await viewModel.fetchAllEvents()
                }
            }
            .onChange(of: locationManager.location) { _, newLocation in
                if let newLocation, !hasCenteredOnUser {
                    centerMapOn(location: newLocation)
                    hasCenteredOnUser = true
                }
            }
            
            // Контейнер для кнопок
            VStack(spacing: 12) {
                locationButton
                MapZoomControls(
                    onZoomIn: { zoom(factor: 0.5) },
                    onZoomOut: { zoom(factor: 2.0) }
                )
            }
            .padding()
            .padding(.top, 50)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
    }
    
    // ИЗМЕНЕНИЕ: Все вспомогательные View и функции теперь находятся здесь,
    // на одном уровне с `body`, а не внутри него.
    
    private var locationButton: some View {
        Button(action: {
            if let userLocation = locationManager.location {
                centerMapOn(location: userLocation)
            }
        }) {
            Image(systemName: "location.fill")
                .font(.headline)
                .padding(10)
                .background(.regularMaterial)
                .foregroundColor(.blue)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
    
    private func zoom(factor: Double) {
        var region = self.region
        region.span.latitudeDelta *= factor
        region.span.longitudeDelta *= factor
        self.region = region
    }
    
    private func centerMapOn(location: CLLocation) {
        withAnimation {
            region.center = location.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }
}
