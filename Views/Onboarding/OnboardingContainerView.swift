import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(AuthState.self) var authState
    @Environment(ServiceContainer.self) var services
    @Environment(\.modelContext) var modelContext
    @State private var viewModel = OnboardingViewModel()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isCreatingUser = false
    
    var body: some View {
        ZStack {
            Color(hex: "0F0F1A")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                progressBar
                
                Group {
                    switch viewModel.currentStep {
                    case 0:
                        OnboardingStep1NameEmail(viewModel: viewModel)
                    case 1:
                        OnboardingStep2HomeGym(viewModel: viewModel)
                    case 2:
                        OnboardingStep3Physical(viewModel: viewModel)
                    case 3:
                        OnboardingStep4Goal(viewModel: viewModel)
                    case 4:
                        OnboardingStep5Injuries(viewModel: viewModel)
                    default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)
                
                bottomButtons
            }
            .padding()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.totalSteps, id: \.self) { step in
                Capsule()
                    .fill(viewModel.currentStep >= step ? Color(hex: "4A90D9") : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.bottom, 32)
    }
    
    private var bottomButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentStep > 0 {
                Button(action: { viewModel.previousStep() }) {
                    Text("Back")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "1A1A2E"))
                        .cornerRadius(12)
                }
            }
            
            Button(action: handleNext) {
                if isCreatingUser {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                } else {
                    Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Get Started" : "Next")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
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
            }
            .disabled(\!viewModel.isValid || isCreatingUser)
            .opacity(viewModel.isValid ? 1 : 0.5)
        }
        .padding(.top, 24)
    }
    
    private func handleNext() {
        if viewModel.currentStep == viewModel.totalSteps - 1 {
            Task {
                do {
                    isCreatingUser = true
                    let user = try await viewModel.createUser(modelContext: modelContext, authService: services.authService)
                    authState.setAuthenticated(user)
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                    isCreatingUser = false
                }
            }
        } else {
            viewModel.nextStep()
        }
    }
}
