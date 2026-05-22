import Foundation
import SwiftData

class MockSubscriptionService: SubscriptionService {
    private let modelContext: ModelContext?

    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
    }

    func isPremium(userId: UUID) -> Bool {
        return user(for: userId)?.isPremium ?? false
    }

    func getAiUsageCount(userId: UUID) -> Int {
        return user(for: userId)?.aiUsageCount ?? 0
    }

    func incrementAiUsage(userId: UUID) async throws {
        guard let user = user(for: userId), let modelContext else { return }
        user.aiUsageCount += 1
        try modelContext.save()
    }

    func canUseAi(userId: UUID) -> Bool {
        guard let user = user(for: userId) else { return false }
        if user.isPremium { return true }
        return user.aiUsageCount < 10
    }

    private func user(for userId: UUID) -> User? {
        guard let modelContext else { return nil }
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userId })
        return try? modelContext.fetch(descriptor).first
    }
}
