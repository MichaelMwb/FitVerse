import SwiftUI
import SwiftData

@main
struct FitVerseApp: App {
    let modelContainer: ModelContainer
    @State private var authState = AuthState()
    @State private var serviceContainer: ServiceContainer

    init() {
        let schema = Schema([
            User.self,
            Workout.self,
            Goal.self,
            CheckIn.self,
            ChatMessage.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        
        _serviceContainer = State(initialValue: ServiceContainer(modelContext: modelContainer.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authState)
                .environment(serviceContainer)
                .modelContainer(modelContainer)
        }
    }
}

@Observable
class AuthState {
    var isAuthenticated: Bool = false
    var currentUser: User?
    var isCheckingAuth: Bool = true
    
    func setAuthenticated(_ user: User) {
        isAuthenticated = true
        currentUser = user
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
    }
}

struct RootView: View {
    @Environment(AuthState.self) var authState
    @Environment(ServiceContainer.self) var services
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else if authState.isAuthenticated {
                MainTabView()
            } else {
                OnboardingContainerView()
            }
        }
        .task {
            checkAuthState()
        }
        .onChange(of: authState.isAuthenticated) { _, newValue in
            if newValue {
                showSplash = false
            }
        }
    }
    
    private func checkAuthState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if services.authService.isAuthenticated() {
                if let user = services.authService.getCurrentUser() {
                    authState.setAuthenticated(user)
                }
            }
            authState.isCheckingAuth = false
            showSplash = false
        }
    }
}
