import SwiftUI

struct OnboardingStep3Physical: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your Physical Info")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("This helps us personalize your workouts")
                .foregroundColor(.gray)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Height (cm)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("170", text: $viewModel.height)
                        .textFieldStyle(DarkTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (kg)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("70", text: $viewModel.weight)
                        .textFieldStyle(DarkTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Gender")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Button(action: { viewModel.selectedGender = gender }) {
                            Text(gender.rawValue)
                                .foregroundColor(viewModel.selectedGender == gender ? .white : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.selectedGender == gender ? Color(hex: "4A90D9") : Color(hex: "1A1A2E"))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
