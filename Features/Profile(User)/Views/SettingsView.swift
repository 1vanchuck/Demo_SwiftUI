import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: Text("Account Settings Screen")) {
                    Label("Account Settings", systemImage: "gearshape")
                }
                NavigationLink(destination: Text("Notifications Screen")) {
                    Label("Notifications", systemImage: "bell.badge")
                }
                NavigationLink(destination: Text("Calendar Sync Screen")) {
                    Label("Calendar Sync Preferences", systemImage: "calendar")
                }
                NavigationLink(destination: Text("Accessibility Screen")) {
                    Label("Accessibility", systemImage: "figure.walk.circle")
                }
                NavigationLink(destination: Text("Customize App Icon Screen")) {
                    Label("Customize App Icon", systemImage: "app.badge")
                }
            }
            
            Section {
                NavigationLink(destination: Text("Help Screen")) {
                    Label("Help", systemImage: "questionmark.circle")
                }
                NavigationLink(destination: Text("About Screen")) {
                    Label("About", systemImage: "info.circle")
                }
            }
            
            Section {
                Button(role: .destructive) {
                    authManager.signOut()
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Profile Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthManager())
    }
}
