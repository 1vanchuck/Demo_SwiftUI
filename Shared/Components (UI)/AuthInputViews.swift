import SwiftUI

// MARK: - Email Input View

struct EmailInputView: View {
    @Binding var email: String
    
    private var isValid: Bool {
        Validators.isValidEmail(email)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            if !email.isEmpty && !isValid {
                Text("Неверный формат email")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Password Input View

struct PasswordInputView: View {
    @Binding var password: String
    let title: String
    
    @State private var showPassword = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .trailing) {
                Group {
                    if showPassword {
                        TextField(title, text: $password)
                    } else {
                        SecureField(title, text: $password)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing, 12)
                }
            }

            if !password.isEmpty && password.count < 8 {
                Text("Пароль должен быть не короче 8 символов")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Confirm Password Input View

struct ConfirmPasswordInputView: View {
    let originalPassword: String
    @Binding var confirmationPassword: String
    
    @State private var showConfirmPassword = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .trailing) {
                Group {
                    if showConfirmPassword {
                        TextField("Подтвердите пароль", text: $confirmationPassword)
                    } else {
                        SecureField("Подтвердите пароль", text: $confirmationPassword)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                Button(action: { showConfirmPassword.toggle() }) {
                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing, 12)
                }
            }
            
            if !confirmationPassword.isEmpty && originalPassword != confirmationPassword {
                Text("Пароли не совпадают")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}
