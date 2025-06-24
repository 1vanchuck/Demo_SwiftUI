import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authManager: AuthManager // Получаем AuthManager из окружения
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let user = viewModel.user {
                        AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable().aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .padding(.top, 20)
                        
                        Text(user.name ?? "No Name")
                            .font(.title).fontWeight(.bold)
                            .padding(.top, 16)
                        
                        HStack(spacing: 16) { /* ... Кнопки Edit и Share ... */ }
                            .padding(.horizontal).padding(.top, 20)

                        if let date = user.dateCreated {
                            Text("Joined \(date.formatted(.dateTime.month().year()))")
                                .font(.subheadline).foregroundColor(.gray).padding(.top, 8)
                        }
                    } else {
                        ProgressView()
                    }
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape").foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                // Вызываем загрузку данных и передаем authManager
                Task {
                    await viewModel.fetchCurrentUser(using: authManager)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
