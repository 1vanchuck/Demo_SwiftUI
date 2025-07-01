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
                .tint(Color(red: 0.45, green: 0.3, blue: 0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            
            if !email.isEmpty && !isValid {
                Text("Invalid email format")
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
                .tint(Color(red: 0.45, green: 0.3, blue: 0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing, 12)
                }
            }
            
            if !password.isEmpty && password.count < 8 {
                Text("Password must be at least 8 characters")
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
                        TextField("Confirm Password", text: $confirmationPassword)
                    } else {
                        SecureField("Confirm Password", text: $confirmationPassword)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .tint(Color(red: 0.45, green: 0.3, blue: 0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                
                Button(action: { showConfirmPassword.toggle() }) {
                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing, 12)
                }
            }
            
            if !confirmationPassword.isEmpty && originalPassword != confirmationPassword {
                Text("Passwords do not match")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}
