import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // Оставляем только одно локальное состояние для подтверждения пароля
    @State private var confirmPassword = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                
                // ИСПОЛЬЗУЕМ НАШИ НОВЫЕ КОМПОНЕНТЫ
                EmailInputView(email: $viewModel.email)
                
                PasswordInputView(password: $viewModel.password, title: "Пароль")
                
                ConfirmPasswordInputView(originalPassword: viewModel.password,
                                           confirmationPassword: $confirmPassword)
                
                // Проверка на совпадение email и пароля
                if !viewModel.email.isEmpty && !viewModel.password.isEmpty && viewModel.email == viewModel.password {
                    Text("Email и пароль не должны совпадать.")
                        .font(.caption).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                }
                
                Spacer()
                
                Button("Создать аккаунт") {
                    viewModel.signUpWithFirebase(confirmPassword: confirmPassword)
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.purple : Color.gray)
                .foregroundStyle(.white)
                .cornerRadius(15)
                .disabled(!isFormValid)
            }
            .padding()
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
        .navigationTitle("Регистрация")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Подтвердите ваш Email", isPresented: $viewModel.showVerificationAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text(viewModel.authError)
        }
    }
    
    private var isFormValid: Bool {
        // Логика валидации остается здесь, но теперь она проверяет все условия
        guard Validators.isValidEmail(viewModel.email),
              viewModel.password.count >= 8,
              viewModel.password == confirmPassword,
              viewModel.email != viewModel.password
        else { return false }
        
        return true
    }
}


#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
