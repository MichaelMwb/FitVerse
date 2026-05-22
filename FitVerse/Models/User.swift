import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var name: String
    var email: String
    var passwordHash: String
    var homeGym: String
    var height: Double // in cm
    var weight: Double // in kg
    var gender: Gender
    var fitnessGoal: FitnessGoal
    var injuries: [String]
    var isPremium: Bool
    var aiUsageCount: Int
    var birthYear: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        email: String = "",
        passwordHash: String = "",
        homeGym: String = "",
        height: Double = 0,
        weight: Double = 0,
        gender: Gender = .other,
        fitnessGoal: FitnessGoal = .generalFitness,
        injuries: [String] = [],
        isPremium: Bool = false,
        aiUsageCount: Int = 0,
        birthYear: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.homeGym = homeGym
        self.height = height
        self.weight = weight
        self.gender = gender
        self.fitnessGoal = fitnessGoal
        self.injuries = injuries
        self.isPremium = isPremium
        self.aiUsageCount = aiUsageCount
        self.birthYear = birthYear
        self.createdAt = createdAt
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum FitnessGoal: String, Codable, CaseIterable {
    case buildMuscle = "Build Muscle"
    case loseWeight = "Lose Weight"
    case maintain = "Maintain"
    case generalFitness = "General Fitness"
    case increaseStrength = "Increase Strength"
    case improveEndurance = "Improve Endurance"
}
