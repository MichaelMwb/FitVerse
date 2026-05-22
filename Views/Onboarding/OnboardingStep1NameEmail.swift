import SwiftUI

struct OnboardingStep1NameEmail: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Create Your Account")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Let's get to know you")
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                TextField("Full Name", text: $viewModel.name)
                    .textFieldStyle(DarkTextFieldStyle())
                    .textContentType(.name)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(DarkTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(DarkTextFieldStyle())
                    .textContentType(.newPassword)
                
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .textFieldStyle(DarkTextFieldStyle())
                    .textContentType(.newPassword)
            }
            
            if \!viewModel.password.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password must:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    PasswordRequirement(text: "Be at least 8 characters", isValid: viewModel.password.count >= 8)
                    PasswordRequirement(text: "Match confirmation", isValid: viewModel.password == viewModel.confirmPassword)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

struct PasswordRequirement: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .gray)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(isValid ? .green : .gray)
        }
    }
}

struct DarkTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "1A1A2E"))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}

extension SecureField {
    func textFieldStyle(_ style: DarkTextFieldStyle) -> some View {
        self
            .padding()
            .background(Color(hex: "1A1A2E"))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}
