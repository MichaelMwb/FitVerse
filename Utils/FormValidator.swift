import Foundation

enum FormValidator {
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }

    static func isValidHeight(_ cm: Double) -> Bool {
        return cm >= 50 && cm <= 280
    }

    static func isValidWeight(_ kg: Double) -> Bool {
        return kg >= 10 && kg <= 500
    }

    static func isValidBirthYear(_ year: Int) -> Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = currentYear - year
        return age >= 13 && age <= 120
    }
}
