import Foundation
import FirebaseAuth
import UIKit
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showAuthErrorAlert = false
    @Published var authError = ""
    @Published var shouldNavigateToProfileDetails = false
    @Published var shouldNavigateToAddProfilePic = false
    @Published var shouldNavigateToMainApp = false
    @Published var showVerificationAlert = false
    
    // Для телефона
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    var isPhoneNumberValid: Bool { phoneNumber.filter { "0"..."9" ~= $0 }.count >= 10 }
    
    // --- ONBOARDING PROFILE STATE ---
    @Published var name: String = ""
    @Published var birthDate: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    var isProfileFormValid: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    // --- SIGN UP FORM VALIDATION ---
    func isSignUpFormValid(confirmPassword: String) -> Bool {
        Validators.isValidEmail(email) &&
        password.count >= 8 &&
        password == confirmPassword &&
        email != password
    }
    // --- LOGIN FORM VALIDATION ---
    var isLoginFormValid: Bool {
        Validators.isValidEmail(email) && !password.isEmpty
    }
    
    // MARK: - Email Authentication
    
    func signUpWithFirebase(confirmPassword: String) {
        guard password == confirmPassword else {
            self.authError = "Пароли не совпадают"; self.showAuthErrorAlert = true; return
        }
        isLoading = true
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                try await authResult.user.sendEmailVerification()
                self.isLoading = false
                self.authError = "Письмо для подтверждения отправлено на \(self.email). Пожалуйста, проверьте вашу почту."
                self.showVerificationAlert = true
            } catch let error as NSError {
                self.isLoading = false; self.handleFirebaseAuthError(error); self.showAuthErrorAlert = true
            }
        }
    }

    func signInWithFirebase() {
        isLoading = true
        Task {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                
                guard authResult.user.isEmailVerified else {
                    self.isLoading = false; self.authError = "Ваш email не подтвержден."; self.showAuthErrorAlert = true; return
                }
                
                let authModel = AuthDataResultModel(uid: authResult.user.uid, email: authResult.user.email)
                let user = try await UserManager.shared.fetchOrCreateUser(auth: authModel)
                
                self.isLoading = false
                
                // "Умная" логика маршрутизации
                if user.name != nil && !user.name!.isEmpty {
                    // Имя есть, теперь проверяем фото
                    if user.profileImageURL != nil && !user.profileImageURL!.isEmpty {
                        // Имя и фото есть -> на главный экран
                        self.shouldNavigateToMainApp = true
                    } else {
                        // Имя есть, а фото нет -> на экран добавления фото
                        self.shouldNavigateToAddProfilePic = true
                    }
                } else {
                    // Имени нет -> на экран ввода деталей
                    self.shouldNavigateToProfileDetails = true
                }
                
            } catch let error as NSError {
                self.isLoading = false; self.handleFirebaseAuthError(error); self.showAuthErrorAlert = true
            }
        }
    }
    
    // MARK: - Profile Setup
    // Теперь saveUserNameAndBirthDate не принимает параметры, а использует состояния
    func saveUserNameAndBirthDate() async {
        isLoading = true
        do {
            guard let userID = Auth.auth().currentUser?.uid else { isLoading = false; return }
            try await UserManager.shared.updateUserNameAndBirthDate(userId: userID, name: name, birthDate: birthDate)
            self.shouldNavigateToAddProfilePic = true
        } catch {
            self.authError = "Не удалось сохранить данные: \(error.localizedDescription)"
            self.showAuthErrorAlert = true
        }
        isLoading = false
    }
    
    func completeProfileSetup(image: UIImage?) async {
        isLoading = true
        do {
            let _ = try? await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
            guard let userID = Auth.auth().currentUser?.uid else { throw URLError(.badURL) }
            if let image = image {
                let url = try await StorageManager.shared.uploadProfilePic(image: image, forUserID: userID)
                try await UserManager.shared.updateUserProfileImage(userId: userID, url: url.absoluteString)
            }
            self.isLoading = false
            self.shouldNavigateToMainApp = true
        } catch {
            self.isLoading = false
            self.authError = "Не удалось обновить профиль: \(error.localizedDescription)"
            self.showAuthErrorAlert = true
        }
    }

    // MARK: - Phone Authentication (Dummy Logic)
    
    func sendVerificationCode() {
        isLoading = true
        print("Отправка кода на номер: \(phoneNumber)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.isLoading = false }
    }

    func checkVerificationCode() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            if self.verificationCode == "1234" {
                self.shouldNavigateToProfileDetails = true
            } else {
                self.authError = "Неверный код"
                self.showAuthErrorAlert = true
            }
        }
    }

    // MARK: - Error Handling
    
    private func handleFirebaseAuthError(_ error: NSError) {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            self.authError = "Произошла неизвестная ошибка. Пожалуйста, попробуйте позже."
            return
        }
        
        switch errorCode {
        case .invalidEmail:
            self.authError = "Пожалуйста, введите корректный адрес электронной почты."
        case .emailAlreadyInUse:
            self.authError = "Этот адрес электронной почты уже используется другим аккаунтом."
        case .weakPassword:
            self.authError = "Пароль слишком слабый. Он должен содержать не менее 6 символов."
        case .wrongPassword, .userNotFound, .invalidCredential:
            self.authError = "Неправильный email или пароль."
        default:
            self.authError = "Произошла неизвестная ошибка. Пожалуйста, попробуйте позже."
        }
    }
}
