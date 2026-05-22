import Foundation
import SwiftData

class MockGoalService: GoalService {
    private let modelContext: ModelContext?

    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
    }

    func getGoals(userId: UUID) async throws -> [Goal] {
        let descriptor = FetchDescriptor<Goal>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext?.fetch(descriptor) ?? []
    }

    func addGoal(userId: UUID, type: GoalType) async throws -> Goal {
        let goal = Goal(
            userId: userId,
            type: type,
            unit: type.defaultUnit
        )
        modelContext?.insert(goal)
        try modelContext?.save()
        return goal
    }

    func updateMetric(goalId: UUID, value: Double) async throws {
        let descriptor = FetchDescriptor<Goal>(predicate: #Predicate { $0.id == goalId })
        guard let goal = try modelContext?.fetch(descriptor).first else { return }
        goal.addEntry(value: value)
        try modelContext?.save()
    }

    func removeGoal(goalId: UUID) async throws {
        let descriptor = FetchDescriptor<Goal>(predicate: #Predicate { $0.id == goalId })
        guard let goal = try modelContext?.fetch(descriptor).first else { return }
        modelContext?.delete(goal)
        try modelContext?.save()
    }
}
