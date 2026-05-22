import Foundation
import SwiftData

class MockSubscriptionService: SubscriptionService {
    private var modelContext: ModelContext?
    private var premiumUsers: Set<UUID> = []
    private var usageCounts: [UUID: Int] = [:]
    
    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
    }
    
    func isPremium(userId: UUID) -> Bool {
        return premiumUsers.contains(userId)
    }
    
    func getAiUsageCount(userId: UUID) -> Int {
        return usageCounts[userId] ?? 0
    }
    
    func incrementAiUsage(userId: UUID) async throws {
        usageCounts[userId] = (usageCounts[userId] ?? 0) + 1
    }
    
    func canUseAi(userId: UUID) -> Bool {
        if isPremium(userId: userId) { return true }
        return getAiUsageCount(userId: userId) < 10 // Free tier: 10 messages
    }
}
