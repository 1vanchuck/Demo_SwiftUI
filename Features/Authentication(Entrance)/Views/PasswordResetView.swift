import SwiftUI
import FirebaseAuth

struct PasswordResetView: View {
    // Локальные состояния для этого экрана
    @State private var email: String
    @State private var error: String?
    @State private var success = false
    
    @Environment(\.dismiss) private var dismiss
    
    // Принимаем начальный email, чтобы поле не было пустым
    init(initialEmail: String) {
        _email = State(initialValue: initialEmail)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Иконка и заголовок
            Image(systemName: "key.fill")
                .font(.largeTitle)
                .foregroundColor(.purple)
                .padding(.top, 40)
            
            Text("Сброс пароля")
                .font(.title2).fontWeight(.bold)
            
            Text("Введите ваш email, и мы отправим вам ссылку для сброса пароля.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Поле ввода
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            // Сообщения об успехе или ошибке
            if let error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            if success {
                Text("Письмо отправлено! Проверьте вашу почту.")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            // Кнопка действия
            Button("Отправить ссылку") {
                Task {
                    do {
                        try await Auth.auth().sendPasswordReset(withEmail: email)
                        self.success = true
                        self.error = nil
                    } catch {
                        self.error = "Не удалось отправить письмо. Проверьте email или попробуйте позже."
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
            .disabled(!isValidEmail(email) || success) // Блокируем после успеха
            
            Spacer()
            
            Button("Закрыть") {
                dismiss()
            }
            .padding(.bottom)
        }
        .padding()
    }
    
    // Функция валидации
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}


#Preview {
    PasswordResetView(initialEmail: "test@example.com")
}
