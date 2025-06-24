import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    deinit {
        if let handle = authStateHandle { Auth.auth().removeStateDidChangeListener(handle) }
    }
    func signOut() {
        do { try Auth.auth().signOut() } catch { print("Error signing out: \(error.localizedDescription)") }
    }
}
