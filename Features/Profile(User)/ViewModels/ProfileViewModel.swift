import Foundation
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: DBUser?

    /// Fetches the current user's profile data from Firestore.
    /// - Parameter authManager: The app's central authentication manager.
    func fetchCurrentUser(using authManager: AuthManager) async {
        // We need the authenticated user from AuthManager to know which document to fetch.
        guard let authUser = authManager.user else {
            print("AuthManager: No authenticated user found.")
            return
        }
        
        do {
            self.user = try await UserManager.shared.getUser(userId: authUser.uid)
        } catch {
            print("Failed to fetch user profile from Firestore: \(error.localizedDescription)")
        }
    }
}
