import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var confirmPassword = ""

    let brandPrimaryColor = Color(red: 0.45, green: 0.3, blue: 0.8)

    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(brandPrimaryColor)
                    .padding(.bottom, 10)
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Let's get you started with the party!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                EmailInputView(email: $viewModel.email)
                PasswordInputView(password: $viewModel.password, title: "Password")
                ConfirmPasswordInputView(
                    originalPassword: viewModel.password,
                    confirmationPassword: $confirmPassword
                )
                
                if !viewModel.email.isEmpty && !viewModel.password.isEmpty && viewModel.email == viewModel.password {
                    Text("Email and password should not be the same.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Create Account") {
                    viewModel.signUpWithFirebase(confirmPassword: confirmPassword)
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? brandPrimaryColor : Color.gray.opacity(0.4))
                .foregroundStyle(.white)
                .cornerRadius(15)
                .disabled(!isFormValid)
                
                HStack {
                    Text("Already have an account?")
                        .foregroundStyle(.gray)
                    Button("Sign In") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(brandPrimaryColor)
                }
                .padding(.top, 5)
            }
            .padding()
            .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Фон, как у Login
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(brandPrimaryColor)
                }
            }
        }
        // Ваш оригинальный Alert
        .alert("Confirm Your Email", isPresented: $viewModel.showVerificationAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text(viewModel.authError)
        }
    }
    
    private var isFormValid: Bool {
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
