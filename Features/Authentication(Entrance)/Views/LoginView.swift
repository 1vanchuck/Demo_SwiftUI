import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var showPassword = false
    @State private var showResetPasswordSheet = false
    
    // ИЗМЕНЕНИЕ: Теперь мы используем нашу общую функцию из Validators
    private var isFormValid: Bool {
        return Validators.isValidEmail(viewModel.email) && !viewModel.password.isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                ZStack(alignment: .trailing) {
                    Group {
                        if showPassword { TextField("Пароль", text: $viewModel.password) }
                        else { SecureField("Пароль", text: $viewModel.password) }
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

                Button("Войти") {
                    viewModel.signInWithFirebase()
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.purple : Color.gray)
                .foregroundStyle(.white)
                .cornerRadius(15)
                .disabled(!isFormValid)

                Button("Забыли пароль?") {
                    showResetPasswordSheet = true
                }
                .font(.footnote)
                .foregroundColor(.purple)
                .padding(.top, 5)
                
                Spacer()
                
                HStack {
                    Text("Впервые здесь?")
                        .foregroundStyle(.gray)
                    NavigationLink("Создать аккаунт", destination: SignUpView())
                        .fontWeight(.semibold)
                        .tint(Color.purple)
                }
            }
            .padding()
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
        .navigationTitle("Вход")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.shouldNavigateToProfileDetails) { EnterNameAndDateView() }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToAddProfilePic) { AddProfilePicView() }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToMainApp) { MainView() }
        .sheet(isPresented: $showResetPasswordSheet) {
            PasswordResetView(initialEmail: viewModel.email)
        }
    }
    
    // ИЗМЕНЕНИЕ: Старая функция isValidEmail отсюда удалена
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
