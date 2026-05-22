import SwiftUI

struct OnboardingStep4Goal: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your Fitness Goal")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("What do you want to achieve?")
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    Button(action: { viewModel.selectedGoal = goal }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.rawValue)
                                    .foregroundColor(.white)
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Spacer()
                            
                            if viewModel.selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "4A90D9"))
                            }
                        }
                        .padding()
                        .background(viewModel.selectedGoal == goal ? Color(hex: "2A2A3E") : Color(hex: "1A1A2E"))
                        .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
