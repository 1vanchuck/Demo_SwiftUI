import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = viewModel.user {
                        ZStack(alignment: .bottomTrailing) {
                            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable().aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            
                            Image(systemName: "camera.circle.fill")
                                .font(.title)
                                .foregroundStyle(.purple, .thinMaterial)
                                .offset(x: 5, y: 5)
                        }
                        .padding(.top, 20)
                        
                        Text(user.name ?? "No Name")
                            .font(.title).bold()
                        
                        HStack(spacing: 12) {
                            Button("Edit profile") {}
                                .buttonStyle(ProfileLightButtonStyle())
                            Button("Share profile") {}
                                .buttonStyle(ProfileLightButtonStyle())
                        }
                        
                        HStack(spacing: 20) {
                            HStack {
                                Image(systemName: "gift.fill").foregroundStyle(.purple)
                                Text("December birthday")
                            }
                            HStack {
                                Image(systemName: "party.popper.fill").foregroundStyle(.purple)
                                if let date = user.dateCreated {
                                    Text("Joined \(date.formatted(.dateTime.month().year()))")
                                }
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        
                        Divider().padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mutuals")
                                .font(.headline)
                            Text("Check back after your first event!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    } else {
                        ProgressView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {}) {
                        HStack {
                            Text(viewModel.user?.name ?? "Profile").bold()
                            Image(systemName: "chevron.down")
                        }
                        .foregroundStyle(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "pencil")
                        }
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchCurrentUser(using: authManager)
                }
            }
        }
        .accentColor(.purple)
    }
}

struct ProfileLightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
