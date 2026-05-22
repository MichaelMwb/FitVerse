import SwiftUI
import SwiftData

struct GoalsView: View {
    @State private var viewModel = GoalsViewModel()
    @Environment(AuthState.self) var authState
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1A")
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.goals.isEmpty {
                    ProgressView()
                        .tint(.white)
                } else if viewModel.goals.isEmpty {
                    emptyStateView
                } else {
                    goalsList
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Text("FitVerse")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: { viewModel.showAddGoal = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "4A90D9"))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddGoal) {
                AddGoalView { goalType in
                    if let user = authState.currentUser {
                        viewModel.addGoal(modelContext: modelContext, userId: user.id, type: goalType)
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        .task {
            if let user = authState.currentUser {
                viewModel.loadGoals(modelContext: modelContext, userId: user.id)
            }
        }
    }
    
    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.goals.filter { $0.isActive }) { goal in
                    GoalCard(goal: goal) { newValue in
                        viewModel.updateMetric(modelContext: modelContext, goal: goal, value: newValue)
                    } onDelete: {
                        viewModel.deleteGoal(modelContext: modelContext, goal: goal)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            if let user = authState.currentUser {
                viewModel.loadGoals(modelContext: modelContext, userId: user.id)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Goals Yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Add your first goal to start tracking your progress!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { viewModel.showAddGoal = true }) {
                Text("Add Goal")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "4A90D9"), Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    let onUpdate: (Double) -> Void
    let onDelete: () -> Void
    
    @State private var showUpdateSheet = false
    @State private var newValue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForType(goal.type))
                    .foregroundColor(Color(hex: "4A90D9"))
                    .font(.title2)
                
                Text(goal.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Menu {
                    Button(action: { showUpdateSheet = true }) {
                        Label("Update", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(goal.type == .streak ? "\(goal.streak)" : String(format: "%.1f", goal.currentValue))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text(goal.unit)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let target = goal.targetValue {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Target")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Int(target)) \(goal.unit)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
            
            if !goal.history.isEmpty {
                progressView
            }
        }
        .padding()
        .background(Color(hex: "1A1A2E"))
        .cornerRadius(16)
        .sheet(isPresented: $showUpdateSheet) {
            NavigationStack {
                VStack(spacing: 24) {
                    Text("Update \(goal.type.rawValue)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter new value", text: $newValue)
                        .textFieldStyle(DarkTextFieldStyle())
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    
                    Button(action: {
                        if let value = Double(newValue) {
                            onUpdate(value)
                            showUpdateSheet = false
                        }
                    }) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "4A90D9"), Color(hex: "8B5CF6")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .disabled(newValue.isEmpty)
                    
                    Spacer()
                }
                .padding()
                .background(Color(hex: "0F0F1A"))
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Cancel") {
                            showUpdateSheet = false
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var progressView: some View {
        let values = goal.history.suffix(7).map { $0.value }
        let maxValue = values.max() ?? 1
        return HStack(spacing: 4) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                let normalized = maxValue > 0 ? CGFloat(value / maxValue) * 26 : 4
                RoundedRectangle(cornerRadius: 2)
                    .fill(index == values.count - 1 ? Color(hex: "4A90D9") : Color(hex: "4A90D9").opacity(0.4))
                    .frame(height: max(normalized, 4))
            }
        }
        .frame(height: 30)
        .background(Color(hex: "252538"))
        .cornerRadius(4)
    }
    
    private func iconForType(_ type: GoalType) -> String {
        switch type {
        case .weight: return "scalemass.fill"
        case .streak: return "flame.fill"
        case .calories: return "flame"
        case .bodyFat: return "percent"
        case .pr: return "trophy.fill"
        case .custom: return "star.fill"
        }
    }
}
