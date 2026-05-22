import SwiftUI

struct AddGoalView: View {
    let onAdd: (GoalType) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1A")
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("Choose a goal type")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(GoalType.allCases.filter { $0 \!= .custom }, id: \.self) { goalType in
                                Button(action: {
                                    onAdd(goalType)
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: iconForType(goalType))
                                            .foregroundColor(Color(hex: "4A90D9"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(goalType.rawValue)
                                                .foregroundColor(.white)
                                                .font(.body)
                                            
                                            Text(descriptionForType(goalType))
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(Color(hex: "4A90D9"))
                                    }
                                    .padding()
                                    .background(Color(hex: "1A1A2E"))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
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
    
    private func descriptionForType(_ type: GoalType) -> String {
        switch type {
        case .weight: return "Track your weight over time"
        case .streak: return "Count consecutive workout days"
        case .calories: return "Monitor daily calorie intake"
        case .bodyFat: return "Track body fat percentage"
        case .pr: return "Record personal records"
        case .custom: return "Create a custom metric"
        }
    }
}
