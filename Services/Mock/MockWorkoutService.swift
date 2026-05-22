import Foundation
import SwiftData

class MockWorkoutService: WorkoutService {
    private let modelContext: ModelContext?
    private let exercises: [Exercise]

    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
        self.exercises = Exercise.loadAll()
    }

    func getWorkouts(userId: UUID) async throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext?.fetch(descriptor) ?? []
    }

    func getTodaysWorkout(userId: UUID) async throws -> Workout? {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { workout in
                workout.userId == userId && workout.date >= today && workout.date < tomorrow
            }
        )
        return try modelContext?.fetch(descriptor).first
    }

    func generateWorkout(userId: UUID, constraints: WorkoutConstraints) async throws -> Workout {
        // Filter exercises based on constraints
        var filteredExercises = exercises

        if !constraints.muscleGroups.isEmpty {
            filteredExercises = filteredExercises.filter { exercise in
                exercise.primaryMuscles.contains { constraints.muscleGroups.contains($0) }
            }
        }

        if !constraints.equipment.isEmpty {
            filteredExercises = filteredExercises.filter { exercise in
                constraints.equipment.contains(exercise.equipment)
            }
        }

        if !constraints.excludeExercises.isEmpty {
            filteredExercises = filteredExercises.filter { exercise in
                !constraints.excludeExercises.contains(exercise.id)
            }
        }

        // Take random exercises for workout
        let workoutExercises = filteredExercises
            .shuffled()
            .prefix(5)
            .map { ExerciseData.toWorkoutExercise($0) }

        let workout = Workout(
            userId: userId,
            date: Date(),
            exercises: workoutExercises
        )

        modelContext?.insert(workout)
        try modelContext?.save()

        return workout
    }

    func updateWorkout(_ workout: Workout) async throws -> Workout {
        try modelContext?.save()
        return workout
    }

    func markComplete(workoutId: UUID) async throws {
        let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.id == workoutId })
        guard let workout = try modelContext?.fetch(descriptor).first else { return }
        workout.completed = true
        try modelContext?.save()
    }
}

struct ExerciseData {
    static func toWorkoutExercise(_ exercise: Exercise) -> WorkoutExercise {
        WorkoutExercise(
            exerciseId: exercise.id,
            sets: 3,
            reps: 10,
            notes: exercise.name
        )
    }
}
