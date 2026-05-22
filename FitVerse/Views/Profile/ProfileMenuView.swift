import SwiftUI

struct ProfileMenuView: View {
    @Environment(AuthState.self) var authState
    @Environment(ServiceContainer.self) var services
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let user = authState.currentUser {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if user.isPremium {
                                Text("PRO")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "4A90D9"), Color(hex: "8B5CF6")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section {
                    menuItem(icon: "person.circle", title: "Edit Profile") {
                        // TODO: Navigate to edit profile
                    }
                    menuItem(icon: "lock.fill", title: "Privacy") {
                        // TODO: Navigate to privacy
                    }
                    menuItem(icon: "doc.text.fill", title: "Legal") {
                        // TODO: Navigate to legal
                    }
                }
                
                Section {
                    menuItem(icon: "rectangle.portrait.and.arrow.right", title: "Logout", color: .red) {
                        logout()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0F0F1A"))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func menuItem(icon: String, title: String, color: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
    }
    
    private func logout() {
        try? services.authService.signOut()
        authState.logout()
        dismiss()
    }
}
