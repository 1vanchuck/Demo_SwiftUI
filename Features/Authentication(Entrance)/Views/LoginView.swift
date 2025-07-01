import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showPassword = false
    @State private var showResetPasswordSheet = false
    
    @Environment(\.dismiss) var dismiss
    
    let brandPrimaryColor = Color(red: 0.45, green: 0.3, blue: 0.8)

    private var isFormValid: Bool {
        return Validators.isValidEmail(viewModel.email) && !viewModel.password.isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                
                Spacer()
                
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 50))
                    .foregroundColor(brandPrimaryColor)
                    .padding(.bottom, 10)
                
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Welcome back, please enter your details.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)

                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .tint(brandPrimaryColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                ZStack(alignment: .trailing) {
                    Group {
                        if showPassword {
                            TextField("Password", text: $viewModel.password)
                        } else {
                            SecureField("Password", text: $viewModel.password)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .tint(brandPrimaryColor)
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

                Button("Login") {
                    viewModel.signInWithFirebase()
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? brandPrimaryColor : Color.gray.opacity(0.4))
                .foregroundStyle(.white)
                .cornerRadius(15)
                .disabled(!isFormValid)
                .padding(.top)

                Button("Forgot your password?") {
                    showResetPasswordSheet = true
                }
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(brandPrimaryColor)
                .padding(.top, 5)
                
                Spacer()
                
                HStack {
                    Text("New here?")
                        .foregroundStyle(.gray)
                    NavigationLink("Create an account", destination: SignUpView())
                        .fontWeight(.semibold)
                        .tint(brandPrimaryColor)
                }
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showResetPasswordSheet) {
            PasswordResetView(initialEmail: viewModel.email)
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(brandPrimaryColor)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
