import SwiftUI
import PhotosUI
import CoreLocation

// MARK: - Event Header Section
struct EventHeaderSection: View {
    @Binding var title: String
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        Section {
            EventCoverPicker(selectedPhotoItem: $selectedPhotoItem, selectedImage: $selectedImage)
                .listRowInsets(EdgeInsets())
            
            TextField("Untitled Event", text: $title, axis: .vertical)
                .font(.largeTitle.weight(.bold))
        }
    }
}

// MARK: - Event Description Section
struct EventDescriptionSection: View {
    @Binding var descriptionText: String
    
    var body: some View {
        Section(header: Text("ADD A DESCRIPTION OF YOUR EVENT (OPTIONAL)")) {
            TextEditor(text: $descriptionText)
                .frame(minHeight: 120)
                .onTapGesture {
                    if descriptionText == "Add a description..." {
                        descriptionText = ""
                    }
                }
        }
    }
}

// MARK: - Event Details Section
struct EventDetailsSection: View {
    @Binding var eventDate: Date
    @Binding var locationName: String
    @Binding var participantLimit: Int
    
    let selectedCoordinates: CLLocationCoordinate2D?
    var onSelectOnMapTapped: () -> Void
    
    var body: some View {
        Section("Details") {
            DatePicker(
                "Set a date",
                selection: $eventDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                TextField("Location Name", text: $locationName)
            }
            
            Button(action: onSelectOnMapTapped) {
                HStack {
                    if let coords = selectedCoordinates {
                        Text("Location Selected")
                            .foregroundColor(.accentColor)
                        Spacer()
                        Text("(\(coords.latitude, specifier: "%.3f"), \(coords.longitude, specifier: "%.3f"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Select on Map")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            Stepper("Guest Spots: \(participantLimit == 0 ? "Unlimited" : "\(participantLimit)")",
                    value: $participantLimit,
                    in: 0...1000,
                    step: 1)
        }
    }
}
