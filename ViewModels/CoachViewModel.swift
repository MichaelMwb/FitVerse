import Foundation
import SwiftUI
import SwiftData

@Observable
class CoachViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var todaysWorkout: Workout?
    
    func loadMessages(modelContext: ModelContext, userId: UUID) {
        let descriptor = FetchDescriptor<ChatMessage>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        do {
            messages = try modelContext.fetch(descriptor)
        } catch {
            messages = []
        }
    }
    
    func sendMessage(modelContext: ModelContext, aiService: AIService, userId: UUID, userGoal: FitnessGoal, injuries: [String]) async {
        let userMessage = ChatMessage(userId: userId, content: inputText, isFromUser: true)
        modelContext.insert(userMessage)
        messages.append(userMessage)
        
        let currentInput = inputText
        inputText = ""
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await aiService.sendMessage(currentInput, context: AIContext(userGoal: userGoal, injuries: injuries, recentWorkouts: []))
            let aiMessage = ChatMessage(userId: userId, content: response, isFromUser: false)
            modelContext.insert(aiMessage)
            messages.append(aiMessage)
            try? modelContext.save()
        } catch {
            let errorMessage = ChatMessage(userId: userId, content: "Sorry, I'm having trouble responding right now. Please try again.", isFromUser: false)
            modelContext.insert(errorMessage)
            messages.append(errorMessage)
        }
    }
    
    func loadTodaysWorkout(workoutService: WorkoutService, userId: UUID) async {
        do {
            todaysWorkout = try await workoutService.getTodaysWorkout(userId: userId)
        } catch {
            todaysWorkout = nil
        }
    }
}
