import SwiftUI
import PhotosUI
import MapKit
import FirebaseFirestore

struct CreateEventView: View {
    @StateObject private var viewModel = EventsViewModel()
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Properties
    @State private var title: String = ""
    @State private var locationName: String = ""
    @State private var descriptionText: String = "Add a description..."
    @State private var eventDate: Date = Date()
    @State private var participantLimit: Int = 0 // 0 = unlimited
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    @State private var showLocationPicker = false
    @State private var selectedCoordinates: CLLocationCoordinate2D?
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCoordinates != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    EventHeaderSection(title: $title,
                                       selectedPhotoItem: $selectedPhotoItem,
                                       selectedImage: $selectedImage)
                    
                    // ИСПОЛЬЗУЕМ НАШ НОВЫЙ КОМПОНЕНТ
                    EventDetailsSection(
                        eventDate: $eventDate,
                        locationName: $locationName,
                        participantLimit: $participantLimit,
                        selectedCoordinates: selectedCoordinates, // Передаем значение
                        onSelectOnMapTapped: { showLocationPicker = true } // Передаем действие
                    )
                    
                    EventDescriptionSection(descriptionText: $descriptionText)
                }
                .navigationTitle("New Event")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveEvent() }
                            .disabled(!isFormValid || viewModel.isLoading)
                    }
                }
                .sheet(isPresented: $showLocationPicker) {
                    LocationPickerView { coordinates in
                        self.selectedCoordinates = coordinates
                    }
                }
                .onChange(of: viewModel.didCreateEvent) { _, success in
                    if success { dismiss() }
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView().tint(.white).scaleEffect(1.5)
                }
            }
        }
    }
    
    private func saveEvent() {
        guard let creatorId = authManager.user?.uid else { return }
        let geoPoint = selectedCoordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
        
        Task {
            await viewModel.createEvent(
                title: title, eventDate: eventDate, locationName: locationName,
                coordinates: geoPoint, description: descriptionText,
                image: selectedImage, creatorId: creatorId,
                participantLimit: participantLimit == 0 ? nil : participantLimit
            )
        }
    }
}
