import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        List {
            Section {
                NavigationLink("Account Settings") {
                    // Заглушка для будущего экрана
                    Text("Account Settings Screen")
                }
                NavigationLink("Notifications") {
                    Text("Notifications Screen")
                }
            }
            
            Section {
                Button("Log out", role: .destructive) {
                    authManager.signOut()
                }
            }
        }
        .navigationTitle("Profile Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
