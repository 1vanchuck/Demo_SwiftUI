import SwiftUI

struct EventDetailView: View {
    @StateObject private var viewModel: EventDetailViewModel
    @EnvironmentObject var authManager: AuthManager

    init(event: Event) {
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Event Cover Image
                AsyncImage(url: URL(string: viewModel.event.imageURL ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.secondary.opacity(0.3))
                }
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.event.title)
                        .font(.largeTitle).bold()
                    
                    InfoRow(iconName: "calendar", text: viewModel.event.eventDate.formatted(.dateTime.day().month().year().hour().minute()))
                    InfoRow(iconName: "mappin.and.ellipse", text: viewModel.event.locationName)
                    
                    if let description = viewModel.event.descriptionText, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .padding(.top, 8)
                    }
                }
                .padding()
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Who's going (\(viewModel.attendees.count))")
                        .font(.headline).padding([.top, .horizontal])
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -10) {
                            ForEach(viewModel.attendees, id: \.userId) { user in
                                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill").font(.title).foregroundColor(.secondary)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            // Join/Leave Button
            if let userId = authManager.user?.uid {
                if viewModel.event.creatorId != userId {
                    rsvpButton(currentUserId: userId)
                        .padding()
                        .background(.thinMaterial)
                }
            }
        }
        .onAppear {
            viewModel.onAppear(currentUserId: authManager.user?.uid)
        }
        .navigationTitle(viewModel.event.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func rsvpButton(currentUserId: String) -> some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
        } else {
            switch viewModel.currentUserRsvpStatus {
            case .going:
                Button("You are going • Leave event", role: .destructive) {
                    Task { await viewModel.leaveEvent(currentUserId: currentUserId) }
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .gray))
                
            case .none, .pending, .cantGo, .maybe:
                Button("Join Event") {
                    Task { await viewModel.joinEvent(currentUserId: currentUserId) }
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .purple))
            }
        }
    }
}

#Preview {
    NavigationStack {
        var previewEvent = Event(
            title: "Summer Music Festival",
            eventDate: Date(),
            locationName: "Cascais, Portugal",
            creatorId: "user123"
        )

        EventDetailView(event: previewEvent)
            .environmentObject(AuthManager())
    }
}
