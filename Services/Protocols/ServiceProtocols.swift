import Foundation

// MARK: - Auth Service Protocol

protocol AuthService {
    func signUp(name: String, email: String, password: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() throws
    func isAuthenticated() -> Bool
    func getCurrentUser() -> User?
}

// MARK: - User Service Protocol

protocol UserService {
    func getUser(id: UUID) async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func updateWeight(userId: UUID, weight: Double) async throws
}

// MARK: - Workout Service Protocol

protocol WorkoutService {
    func getWorkouts(userId: UUID) async throws -> [Workout]
    func getTodaysWorkout(userId: UUID) async throws -> Workout?
    func generateWorkout(userId: UUID, constraints: WorkoutConstraints) async throws -> Workout
    func updateWorkout(_ workout: Workout) async throws -> Workout
    func markComplete(workoutId: UUID) async throws
}

struct WorkoutConstraints {
    let duration: Int? // minutes
    let equipment: [String]
    let muscleGroups: [String]
    let excludeExercises: [String]
    let fitnessLevel: String
}

// MARK: - Social Service Protocol

protocol SocialService {
    func getFeed() async throws -> [SocialPost]
}

struct SocialPost: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let imageURL: String?
    let author: String
    let likes: Int
    let category: String

    static func placeholder() -> [SocialPost] {
        [
            SocialPost(id: UUID(), title: "5 Tips for Better Form", content: "Focus on controlled movements and proper breathing...", imageURL: nil, author: "FitVerse Team", likes: 234, category: "Tips"),
            SocialPost(id: UUID(), title: "Progressive Overload Explained", content: "The key to building muscle is gradually increasing weight...", imageURL: nil, author: "Coach Mike", likes: 189, category: "Training"),
            SocialPost(id: UUID(), title: "Recovery Matters", content: "Sleep and nutrition are just as important as your workout...", imageURL: nil, author: "FitVerse Team", likes: 156, category: "Recovery"),
            SocialPost(id: UUID(), title: "Master the Bench Press", content: "Keep your shoulder blades retracted and drive through your feet...", imageURL: nil, author: "Coach Sarah", likes: 312, category: "Technique"),
            SocialPost(id: UUID(), title: "Nutrition Basics", content: "Protein is essential for muscle repair and growth...", imageURL: nil, author: "FitVerse Team", likes: 278, category: "Nutrition")
        ]
    }
}

// MARK: - AI Service Protocol

protocol AIService {
    func sendMessage(_ message: String, context: AIContext) async throws -> String
    func updateWorkoutFromChat(userId: UUID, conversation: [ChatMessage]) async throws -> Workout?
}

struct AIContext {
    let userGoal: FitnessGoal
    let injuries: [String]
    let recentWorkouts: [Workout]
}

// MARK: - Goal Service Protocol

protocol GoalService {
    func getGoals(userId: UUID) async throws -> [Goal]
    func addGoal(userId: UUID, type: GoalType) async throws -> Goal
    func updateMetric(goalId: UUID, value: Double) async throws
    func removeGoal(goalId: UUID) async throws
}

// MARK: - Subscription Service Protocol

protocol SubscriptionService {
    func isPremium(userId: UUID) -> Bool
    func getAiUsageCount(userId: UUID) -> Int
    func incrementAiUsage(userId: UUID) async throws
    func canUseAi(userId: UUID) -> Bool
}
