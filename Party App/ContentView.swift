import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            if authManager.user != nil {
                MainView()
            } else {
                NavigationStack { WelcomeView() }
            }
        }
        .alert("Error", isPresented: $authViewModel.showAuthErrorAlert) {
            Button("OK") { }
        } message: {
            Text(authViewModel.authError)
        }
    }
}
