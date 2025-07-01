import SwiftUI
import FirebaseAuth

struct PasswordResetView: View {
    // MARK: - Local State
    @State private var email: String
    @State private var error: String?
    @State private var success = false
    
    @Environment(\.dismiss) private var dismiss
    
    init(initialEmail: String) {
        _email = State(initialValue: initialEmail)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "key.fill")
                .font(.largeTitle)
                .foregroundColor(.purple)
                .padding(.top, 40)
            
            Text("Password Reset")
                .font(.title2).fontWeight(.bold)
            
            Text("Enter your email and we will send you a link to reset your password.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            if let error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            if success {
                Text("Email sent! Please check your inbox.")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            Button("Send Link") {
                Task {
                    do {
                        try await Auth.auth().sendPasswordReset(withEmail: email)
                        self.success = true
                        self.error = nil
                    } catch {
                        self.error = "Failed to send email. Check the address or try again later."
                        self.success = false
                    }
                }
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isValidEmail(email) ? Color.purple : Color.gray)
            .foregroundStyle(.white)
            .cornerRadius(15)
            .disabled(!isValidEmail(email) || success)
            
            Spacer()
            
            Button("Close") {
                dismiss()
            }
            .padding(.bottom)
        }
        .padding()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}


#Preview {
    PasswordResetView(initialEmail: "test@example.com")
}
