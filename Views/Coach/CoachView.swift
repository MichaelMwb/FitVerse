import SwiftUI
import SwiftData

struct CoachView: View {
    @State private var viewModel = CoachViewModel()
    @Environment(AuthState.self) var authState
    @Environment(ServiceContainer.self) var services
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1A")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Today's workout card
                    if let workout = viewModel.todaysWorkout {
                        todaysWorkoutCard(workout)
                            .padding()
                    }
                    
                    // Chat interface
                    chatView
                    
                    // Input area
                    inputArea
                }
            }
            .navigationTitle("AI Coach")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("FitVerse")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .task {
            if let user = authState.currentUser {
                viewModel.loadMessages(modelContext: modelContext, userId: user.id)
                await viewModel.loadTodaysWorkout(workoutService: services.workoutService, userId: user.id)
            }
        }
    }
    
    private func todaysWorkoutCard(_ workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Workout")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            ForEach(workout.exercises.prefix(3), id: \.exerciseId) { exercise in
                HStack {
                    Circle()
                        .fill(exercise.completed ? Color.green : Color(hex: "4A90D9"))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: exercise.completed ? "checkmark" : "")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                    
                    Text("Exercise \(exercise.exerciseId)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(exercise.sets)×\(exercise.reps)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if workout.exercises.count > 3 {
                Text("+\(workout.exercises.count - 3) more exercises")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(hex: "1A1A2E"))
        .cornerRadius(16)
    }
    
    private var chatView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "4A90D9"))
                            
                            Text("Ask me anything about fitness\!")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("I can help with workouts, form tips, nutrition, and more.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Ask your coach...", text: $viewModel.inputText)
                .textFieldStyle(DarkTextFieldStyle())
                .onSubmit {
                    Task { await sendMessage() }
                }
            
            Button(action: { Task { await sendMessage() } }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(viewModel.inputText.isEmpty ? .gray : Color(hex: "4A90D9"))
            }
            .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color(hex: "1A1A2E"))
    }
    
    private func sendMessage() async {
        guard viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty == false,
              let user = authState.currentUser else { return }
        
        await viewModel.sendMessage(
            modelContext: modelContext,
            aiService: services.aiService,
            userId: user.id,
            userGoal: user.fitnessGoal,
            injuries: user.injuries
        )
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(message.isFromUser ? .white : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromUser
                            ? LinearGradient(
                                colors: [Color(hex: "4A90D9"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : AnyShapeStyle(Color(hex: "1A1A2E"))
                    )
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if \!message.isFromUser {
                Spacer(minLength: 60)
            }
        }
    }
}
