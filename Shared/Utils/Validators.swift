import Foundation

struct Validators {
    
    /// Checks if a string matches a standard email format.
    /// - Parameter email: The string to validate.
    /// - Returns: `true` if the email is valid, otherwise `false`.
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Other validators for phone numbers, usernames, etc., can be added here in the future.
}
