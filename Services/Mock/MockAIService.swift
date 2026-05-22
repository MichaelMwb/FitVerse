import Foundation

class MockAIService: AIService {
    private let mockResponses = [
        "Great question! Based on your fitness goal of building muscle, I recommend focusing on compound movements like squats, deadlifts, and bench press.",
        "Remember to prioritize proper form over heavy weights. It's better to lift lighter with good technique than risk injury.",
        "For your goal, aim for 3-4 workouts per week with at least one rest day between sessions.",
        "Make sure you're getting enough protein - roughly 1.6-2.2g per kg of bodyweight for muscle building.",
        "I've updated your workout based on our conversation. You can see the changes in your daily workout.",
        "If you're feeling sore, consider doing some light stretching or a gentle walk as active recovery.",
        "Consistency is key! Try to stick to your workout schedule even when you don't feel 100% motivated.",
        "Don't forget to track your progress - even small improvements add up over time!"
    ]

    func sendMessage(_ message: String, context: AIContext) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Return a random mock response
        return mockResponses.randomElement() ?? "I'm here to help with your fitness journey!"
    }

    func updateWorkoutFromChat(userId: UUID, conversation: [ChatMessage]) async throws -> Workout? {
        // Mock: In real implementation, parse conversation and adjust workout
        return nil
    }
}
