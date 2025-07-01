import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = EventsViewModel()
    @EnvironmentObject var locationManager: LocationManager

    // MARK: - State for Filters
    @State private var selectedEventType: EventType? = nil
    @State private var minAge: Double = 18
    @State private var maxAge: Double = 40
    @State private var selectedGenders: Set<Gender> = []
    
    @State private var showAgeFilterSheet = false
    @State private var showGenderFilterSheet = false

    // MARK: - Map State
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.70, longitude: -9.42),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var hasCenteredOnUser = false
    @State private var selectedEvent: Event?

    var body: some View {
        ZStack {
            // MARK: - Map
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: viewModel.eventsWithCoordinates) { event in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: event.coordinates!.latitude,
                    longitude: event.coordinates!.longitude
                )) {
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

            // MARK: - Top Filter Bar
            VStack {
                filterBar
                    .padding(.top, 5)
                Spacer()
            }

            // MARK: - Bottom Right Controls
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        locationButton
                        MapZoomControls(
                            onZoomIn: { zoom(factor: 0.5) },
                            onZoomOut: { zoom(factor: 2.0) }
                        )
                    }
                }
            }
            .padding()

        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
        .sheet(isPresented: $showAgeFilterSheet) {
            AgeSliderView(minAge: $minAge, maxAge: $maxAge)
                .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $showGenderFilterSheet) {
            GenderSelectionView(selectedGenders: $selectedGenders)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Filter Bar View
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Type Filter
                Menu {
                    ForEach(EventType.allCases) { type in
                        Button(action: { selectedEventType = type }) {
                            Label(type.rawValue, systemImage: selectedEventType == type ? "checkmark" : type.icon)
                        }
                    }
                    if selectedEventType != nil {
                        Divider()
                        Button(role: .destructive, action: { selectedEventType = nil }) {
                            Label("Clear", systemImage: "xmark")
                        }
                    }
                } label: {
                    FilterButton(
                        title: selectedEventType?.rawValue ?? "Type",
                        icon: selectedEventType?.icon ?? "line.3.horizontal.decrease.circle",
                        isSelected: selectedEventType != nil
                    )
                }

                // Age Filter
                Button(action: { showAgeFilterSheet = true }) {
                    FilterButton(
                        title: "Age: \(Int(minAge))-\(Int(maxAge))",
                        icon: "person.2.badge.gear",
                        isSelected: false
                    )
                }

                // Gender Filter
                Button(action: { showGenderFilterSheet = true }) {
                    FilterButton(
                        title: selectedGenders.isEmpty ? "Gender" : "\(selectedGenders.count) selected",
                        icon: "person.2.circle",
                        isSelected: !selectedGenders.isEmpty
                    )
                }

                // Date Filter (inactive)
                Button(action: {}) {
                    FilterButton(
                        title: "Date",
                        icon: "calendar",
                        isSelected: false
                    )
                }
                .disabled(true)
            }
            .padding(.horizontal)
        }
        .background(.ultraThinMaterial.opacity(0.8))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: - Map Control Views and Functions
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
        withAnimation {
            self.region = region
        }
    }

    private func centerMapOn(location: CLLocation) {
        withAnimation {
            region.center = location.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }
}

#Preview {
    let locationManager = LocationManager()
    let authManager = AuthManager()

    MapView()
        .environmentObject(locationManager)
        .environmentObject(authManager)
}
