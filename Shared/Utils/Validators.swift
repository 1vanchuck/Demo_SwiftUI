import Foundation

struct Validators {
    
    /// Проверяет, соответствует ли строка формату email.
    /// - Parameter email: Строка для проверки.
    /// - Returns: `true`, если email валидный, иначе `false`.
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // В будущем сюда можно будет добавить другие валидаторы,
    // например, для проверки номера телефона, имени пользователя и т.д.
}
