import SwiftUI

struct OnboardingStep2HomeGym: View {
    @Bindable var viewModel: OnboardingViewModel
    
    let gymOptions = GymLocation.mockGyms()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your Home Gym")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Where do you usually work out?")
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                ForEach(Array(gymOptions.enumerated()), id: \.element.id) { index, gym in
                    Button(action: {
                        viewModel.selectedGymIndex = index
                        viewModel.homeGym = gym.name
                    }) {
                        HStack {
                            Text(gym.name)
                                .foregroundColor(.white)
                                .font(.body)
                            
                            Spacer()
                            
                            if viewModel.selectedGymIndex == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "4A90D9"))
                            }
                        }
                        .padding()
                        .background(viewModel.selectedGymIndex == index ? Color(hex: "2A2A3E") : Color(hex: "1A1A2E"))
                        .cornerRadius(12)
                    }
                }
                
                Text("Or enter your gym:")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                TextField("Custom gym name", text: $viewModel.homeGym)
                    .textFieldStyle(DarkTextFieldStyle())
                    .onChange(of: viewModel.homeGym) { _, newValue in
                        if \!newValue.isEmpty {
                            viewModel.selectedGymIndex = -1
                        }
                    }
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
