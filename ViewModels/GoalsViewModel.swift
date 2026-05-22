import Foundation
import SwiftUI
import SwiftData

@Observable
class GoalsViewModel {
    var goals: [Goal] = []
    var isLoading: Bool = false
    var showAddGoal: Bool = false
    
    func loadGoals(modelContext: ModelContext, userId: UUID) {
        isLoading = true
        defer { isLoading = false }
        
        let descriptor = FetchDescriptor<Goal>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            goals = try modelContext.fetch(descriptor)
        } catch {
            goals = []
        }
    }
    
    func addGoal(modelContext: ModelContext, userId: UUID, type: GoalType) {
        let goal = Goal(
            userId: userId,
            type: type,
            currentValue: 0,
            unit: type.defaultUnit
        )
        modelContext.insert(goal)
        try? modelContext.save()
        loadGoals(modelContext: modelContext, userId: userId)
    }
    
    func updateMetric(modelContext: ModelContext, goal: Goal, value: Double) {
        goal.addEntry(value: value)
        try? modelContext.save()
        loadGoals(modelContext: modelContext, userId: goal.userId)
    }
    
    func deleteGoal(modelContext: ModelContext, goal: Goal) {
        modelContext.delete(goal)
        try? modelContext.save()
        
        if let userId = goals.first?.userId {
            loadGoals(modelContext: modelContext, userId: userId)
        }
    }
}
