import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var userId: UUID
    var date: Date
    var exercises: [WorkoutExercise]
    var completed: Bool
    var notes: String?

    init(
        id: UUID = UUID(),
        userId: UUID,
        date: Date = Date(),
        exercises: [WorkoutExercise] = [],
        completed: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.exercises = exercises
        self.completed = completed
        self.notes = notes
    }
}

struct WorkoutExercise: Codable {
    var exerciseId: String
    var sets: Int
    var reps: Int
    var weight: Double?
    var duration: Double? // seconds
    var notes: String?
    var completed: Bool

    init(
        exerciseId: String,
        sets: Int = 3,
        reps: Int = 10,
        weight: Double? = nil,
        duration: Double? = nil,
        notes: String? = nil,
        completed: Bool = false
    ) {
        self.exerciseId = exerciseId
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.notes = notes
        self.completed = completed
    }
}
