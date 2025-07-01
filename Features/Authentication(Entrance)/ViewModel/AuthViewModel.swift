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
    
    // Phone Authentication State
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    var isPhoneNumberValid: Bool { phoneNumber.filter { "0"..."9" ~= $0 }.count >= 10 }
    
    // Onboarding Profile State
    @Published var name: String = ""
    @Published var birthDate: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    var isProfileFormValid: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    // MARK: - Form Validation
    
    func isSignUpFormValid(confirmPassword: String) -> Bool {
        Validators.isValidEmail(email) &&
        password.count >= 8 &&
        password == confirmPassword &&
        email != password
    }

    var isLoginFormValid: Bool {
        Validators.isValidEmail(email) && !password.isEmpty
    }
    
    // MARK: - Email Authentication
    
    func signUpWithFirebase(confirmPassword: String) {
        guard password == confirmPassword else {
            self.authError = "Passwords do not match."; self.showAuthErrorAlert = true; return
        }
        isLoading = true
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                try await authResult.user.sendEmailVerification()
                self.isLoading = false
                self.authError = "A verification email has been sent to \(self.email). Please check your inbox."
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
                    self.isLoading = false; self.authError = "Your email has not been verified."; self.showAuthErrorAlert = true; return
                }
                
                let authModel = AuthDataResultModel(uid: authResult.user.uid, email: authResult.user.email)
                let user = try await UserManager.shared.fetchOrCreateUser(auth: authModel)
                
                self.isLoading = false
                
                // Smart routing logic after login: directs the user to the next appropriate
                // step in the onboarding process if their profile is incomplete.
                if user.name != nil && !user.name!.isEmpty {
                    if user.profileImageURL != nil && !user.profileImageURL!.isEmpty {
                        // Name and photo exist -> go to main app
                        self.shouldNavigateToMainApp = true
                    } else {
                        // Name exists, but no photo -> go to add profile pic screen
                        self.shouldNavigateToAddProfilePic = true
                    }
                } else {
                    // Name does not exist -> go to enter profile details screen
                    self.shouldNavigateToProfileDetails = true
                }
                
            } catch let error as NSError {
                self.isLoading = false; self.handleFirebaseAuthError(error); self.showAuthErrorAlert = true
            }
        }
    }
    
    // MARK: - Profile Setup
    
    func saveUserNameAndBirthDate() async {
        isLoading = true
        do {
            guard let userID = Auth.auth().currentUser?.uid else { isLoading = false; return }
            try await UserManager.shared.updateUserNameAndBirthDate(userId: userID, name: name, birthDate: birthDate)
            self.shouldNavigateToAddProfilePic = true
        } catch {
            self.authError = "Failed to save profile data: \(error.localizedDescription)"
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
            self.authError = "Failed to update profile: \(error.localizedDescription)"
            self.showAuthErrorAlert = true
        }
    }

    // MARK: - Phone Authentication (Dummy Logic)
    
    func sendVerificationCode() {
        isLoading = true
        print("Sending code to number: \(phoneNumber)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.isLoading = false }
    }

    func checkVerificationCode() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            if self.verificationCode == "1234" {
                self.shouldNavigateToProfileDetails = true
            } else {
                self.authError = "Invalid code"
                self.showAuthErrorAlert = true
            }
        }
    }

    // MARK: - Error Handling
    
    private func handleFirebaseAuthError(_ error: NSError) {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            self.authError = "An unknown error occurred. Please try again later."
            return
        }
        
        switch errorCode {
        case .invalidEmail:
            self.authError = "Please enter a valid email address."
        case .emailAlreadyInUse:
            self.authError = "This email address is already in use by another account."
        case .weakPassword:
            self.authError = "The password is too weak. It must be at least 6 characters long."
        case .wrongPassword, .userNotFound, .invalidCredential:
            self.authError = "Incorrect email or password."
        default:
            self.authError = "An unknown error occurred. Please try again later."
        }
    }
}
