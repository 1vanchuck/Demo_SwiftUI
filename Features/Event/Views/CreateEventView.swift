import SwiftUI
import PhotosUI
import MapKit
import FirebaseFirestore

struct CreateEventView: View {
    // MARK: - Core State (Functionality preserved)
    @StateObject private var viewModel = EventsViewModel()
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var locationName: String = ""
    @State private var descriptionText: String = ""
    @State private var eventDate: Date = Date()
    @State private var participantLimit: Int = 0
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedCoordinates: CLLocationCoordinate2D?
    @State private var showLocationPicker = false
    
    // MARK: - New Design State
    @State private var selectedEventType: EventType? = .party
    @State private var costPerPerson: Double = 0
    @State private var isOpenInvite: Bool = true

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCoordinates != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.clear, Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        titleSection
                        eventTypeSection
                        EventCoverPicker(selectedPhotoItem: $selectedPhotoItem, selectedImage: $selectedImage)
                            .padding(.horizontal)
                        detailsSection
                        actionButtonsSection
                        descriptionSection
                        moreSectionsPlaceholder
                        openInviteSection
                        quickActionsSection
                    }
                    .padding(.vertical)
                }
                .scrollIndicators(.hidden)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
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
    
    // MARK: - Save Function (Unchanged)
    private func saveEvent() {
        guard let creatorId = authManager.user?.uid else { return }
        let geoPoint = selectedCoordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
        
        let cleanDescription = descriptionText == "Start typing here..." ? "" : descriptionText
        
        Task {
            await viewModel.createEvent(
                title: title, eventDate: eventDate, locationName: locationName,
                coordinates: geoPoint, description: cleanDescription,
                image: selectedImage, creatorId: creatorId,
                participantLimit: participantLimit == 0 ? nil : participantLimit
            )
        }
    }
}


// MARK: - UI Sections (New Design)
private extension CreateEventView {
    
    var titleSection: some View {
        TextField("New Event", text: $title, axis: .vertical)
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    var eventTypeSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(EventType.allCases) { type in
                    Button(action: { selectedEventType = type }) {
                        FilterButton(
                            title: type.rawValue,
                            icon: type.icon,
                            isSelected: selectedEventType == type
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var detailsSection: some View {
        VStack(spacing: 1) {
            DatePicker(selection: $eventDate, displayedComponents: [.date, .hourAndMinute]) { Text("Set a date") }
            Divider()
            HStack {
                Text("Location Name")
                Spacer()
                TextField("e.g., Central Park", text: $locationName)
                    .multilineTextAlignment(.trailing)
            }
            Divider()
            Button(action: { showLocationPicker = true }) {
                HStack {
                    Text("Select on Map")
                    Spacer()
                    if selectedCoordinates != nil {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.purple)
                    } else {
                        Image(systemName: "chevron.right").foregroundColor(.secondary)
                    }
                }
            }
            Divider()
            Stepper("Guest Spots: \(participantLimit == 0 ? "Unlimited" : "\(participantLimit)")", value: $participantLimit, in: 0...1000, step: 1)
            Divider()
            HStack {
                Text("Cost per person")
                Spacer()
                TextField("0", value: $costPerPerson, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }

    @ViewBuilder
    func horizontalActionButton(title: String, icon: String) -> some View {
        Button(action: {}) {
            Label(title, systemImage: icon)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.purple.opacity(0.15))
        .foregroundColor(.purple)
    }

    var actionButtonsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                horizontalActionButton(title: "Link", icon: "plus")
                horizontalActionButton(title: "Playlist", icon: "plus")
                horizontalActionButton(title: "Dress Code", icon: "plus")
                horizontalActionButton(title: "Food", icon: "plus")
                horizontalActionButton(title: "Parking", icon: "plus")
                horizontalActionButton(title: "Info", icon: "plus")
            }
            .padding(.horizontal)
        }
    }
    
    var descriptionSection: some View {
        VStack(alignment: .leading) {
            Text("Event Description").font(.headline)
            TextEditor(text: $descriptionText)
                .onTapGesture {
                    if descriptionText.isEmpty || descriptionText == "Start typing here..." {
                        descriptionText = ""
                    }
                }
                .onAppear {
                    if descriptionText.isEmpty {
                        descriptionText = "Start typing here..."
                    }
                }
                .frame(minHeight: 120)
                .padding(8)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal)
    }
    
    var moreSectionsPlaceholder: some View {
        HStack {
            Text("More to say?").font(.headline)
            Spacer()
            Button(action: {}) {
                Label("New Section", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            .tint(.purple)
        }
        .padding(.horizontal)
    }
    
    var openInviteSection: some View {
        Toggle(isOn: $isOpenInvite) {
            Text("Open Invite").font(.headline)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
    
    var quickActionsSection: some View {
        VStack(alignment: .leading) {
            Text("Quick actions for host").font(.headline).padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    horizontalActionButton(title: "Questionnaire", icon: "plus.bubble")
                    horizontalActionButton(title: "Reminders", icon: "bell")
                    horizontalActionButton(title: "More", icon: "ellipsis.circle")
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    CreateEventView()
        .environmentObject(AuthManager())
}
