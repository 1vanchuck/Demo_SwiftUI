import Foundation
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: DBUser?

    // Убираем init(), загрузку будем вызывать из View
    
    // Функция теперь принимает AuthManager как параметр
    func fetchCurrentUser(using authManager: AuthManager) async {
        // Проверяем, есть ли залогиненный пользователь в AuthManager
        guard let authUser = authManager.user else {
            print("AuthManager: No authenticated user found.")
            return
        }
        
        do {
            // Загружаем наш кастомный DBUser из Firestore
            self.user = try await UserManager.shared.getUser(userId: authUser.uid)
        } catch {
            print("Failed to fetch user profile from Firestore: \(error.localizedDescription)")
        }
    }
}
