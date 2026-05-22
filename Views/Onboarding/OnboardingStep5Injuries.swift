import SwiftUI

struct OnboardingStep5Injuries: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Any Injuries or Limitations?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("This helps us customize your workouts safely")
                .foregroundColor(.gray)
            
            Text("List any injuries, separated by commas")
                .font(.caption)
                .foregroundColor(.gray)
            
            TextEditor(text: $viewModel.injuries)
                .scrollContentBackground(.hidden)
                .padding()
                .background(Color(hex: "1A1A2E"))
                .cornerRadius(12)
                .foregroundColor(.white)
                .frame(minHeight: 120)
            
            Text("Example: Lower back pain, Right shoulder injury")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }
}
