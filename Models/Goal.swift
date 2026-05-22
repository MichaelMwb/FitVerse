import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var userId: UUID
    var type: GoalType
    var currentValue: Double
    var targetValue: Double?
    var unit: String
    var isActive: Bool
    var createdAt: Date
    var history: [MetricEntry]

    init(
        id: UUID = UUID(),
        userId: UUID,
        type: GoalType,
        currentValue: Double = 0,
        targetValue: Double? = nil,
        unit: String = "",
        isActive: Bool = true,
        createdAt: Date = Date(),
        history: [MetricEntry] = []
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.unit = unit
        self.isActive = isActive
        self.createdAt = createdAt
        self.history = history
    }

    func addEntry(value: Double) {
        let entry = MetricEntry(goalId: id, value: value, date: Date())
        history.append(entry)
        currentValue = value
    }

    var streak: Int {
        guard type == .streak else { return Int(currentValue) }

        let sortedDates = history
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted(by: >)

        var streakCount = 0
        var previousDate: Date?

        for date in sortedDates {
            if let prev = previousDate {
                let daysDiff = Calendar.current.dateComponents([.day], from: date, to: prev).day ?? 0
                if daysDiff == 1 {
                    streakCount += 1
                } else {
                    break
                }
            } else {
                let today = Calendar.current.startOfDay(for: Date())
                let daysDiff = Calendar.current.dateComponents([.day], from: date, to: today).day ?? 0
                if daysDiff <= 1 {
                    streakCount = 1
                } else {
                    break
                }
            }
            previousDate = date
        }

        return streakCount
    }
}

enum GoalType: String, Codable, CaseIterable {
    case weight = "Weight"
    case streak = "Streak"
    case calories = "Calories"
    case bodyFat = "Body Fat"
    case pr = "Personal Record"
    case custom = "Custom"

    var defaultUnit: String {
        switch self {
        case .weight: return "kg"
        case .streak: return "days"
        case .calories: return "kcal"
        case .bodyFat: return "%"
        case .pr: return "kg"
        case .custom: return ""
        }
    }
}

struct MetricEntry: Identifiable, Codable {
    let id: UUID
    let goalId: UUID
    let value: Double
    let date: Date
    let notes: String?

    init(
        id: UUID = UUID(),
        goalId: UUID,
        value: Double,
        date: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.goalId = goalId
        self.value = value
        self.date = date
        self.notes = notes
    }
}
