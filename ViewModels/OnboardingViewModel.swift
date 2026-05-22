import Foundation
import SwiftData
import SwiftUI

@Observable
class OnboardingViewModel {
    var currentStep: Int = 0
    let totalSteps = 5
    
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    
    var homeGym: String = ""
    var selectedGymIndex: Int = -1
    
    var height: String = ""
    var weight: String = ""
    var selectedGender: Gender = .other
    var heightInCm: Double { Double(height) ?? 0 }
    var weightInKg: Double { Double(weight) ?? 0 }
    
    var selectedGoal: FitnessGoal = .generalFitness
    
    var injuries: String = ""
    var injuryList: [String] { injuries.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { \!$0.isEmpty } }
    
    var isValid: Bool {
        switch currentStep {
        case 0:
            return \!name.isEmpty && FormValidator.isValidEmail(email) && FormValidator.isValidPassword(password) && password == confirmPassword
        case 1:
            return selectedGymIndex >= 0 || \!homeGym.isEmpty
        case 2:
            return heightInCm > 0 && weightInKg > 0
        case 3:
            return true
        case 4:
            return true
        default:
            return false
        }
    }
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func createUser(modelContext: ModelContext, authService: AuthService) async throws -> User {
        let user = User(
            name: name,
            email: email,
            passwordHash: password.data(using: .utf8)\!.base64EncodedString(),
            homeGym: homeGym,
            height: heightInCm,
            weight: weightInKg,
            gender: selectedGender,
            fitnessGoal: selectedGoal,
            injuries: injuryList
        )
        
        modelContext.insert(user)
        try modelContext.save()
        
        try await authService.signUp(name: name, email: email, password: password)
        
        return user
    }
}
