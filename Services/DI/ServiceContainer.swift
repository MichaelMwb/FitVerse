import Foundation
import SwiftData

@Observable
class ServiceContainer {
    let authService: AuthService
    let userService: UserService
    let workoutService: WorkoutService
    let socialService: SocialService
    let aiService: AIService
    let goalService: GoalService
    let subscriptionService: SubscriptionService

    init(modelContext: ModelContext?) {
        self.authService = MockAuthService(modelContext: modelContext)
        self.userService = MockUserService(modelContext: modelContext)
        self.workoutService = MockWorkoutService(modelContext: modelContext)
        self.socialService = MockSocialService()
        self.aiService = MockAIService()
        self.goalService = MockGoalService(modelContext: modelContext)
        self.subscriptionService = MockSubscriptionService(modelContext: modelContext)
    }
}
