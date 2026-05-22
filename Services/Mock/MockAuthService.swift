import Foundation
import SwiftData
import Security

class MockAuthService: AuthService {
    private var currentUser: User?
    private let modelContext: ModelContext?

    private let keychainKey = "fitverse_current_user_id"

    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
        loadCurrentUser()
    }

    func signUp(name: String, email: String, password: String) async throws -> User {
        let user = User(
            name: name,
            email: email,
            passwordHash: hashPassword(password),
            createdAt: Date()
        )

        modelContext?.insert(user)
        try? modelContext?.save()

        currentUser = user
        saveToKeychain(userId: user.id)

        return user
    }

    func signIn(email: String, password: String) async throws -> User {
        // Mock: find user by email
        var descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
        let users = try? modelContext?.fetch(descriptor)
        guard let user = users?.first else {
            throw AuthError.userNotFound
        }

        // In real app, verify password hash
        currentUser = user
        saveToKeychain(userId: user.id)

        return user
    }

    func signOut() throws {
        currentUser = nil
        deleteFromKeychain()
    }

    func isAuthenticated() -> Bool {
        return currentUser != nil
    }

    func getCurrentUser() -> User? {
        return currentUser
    }

    private func hashPassword(_ password: String) -> String {
        // In real app, use proper hashing (bcrypt, argon2)
        return password.data(using: .utf8)!.base64EncodedString()
    }

    private func saveToKeychain(userId: UUID) {
        let data = userId.uuidString.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadCurrentUser() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        guard let data = result as? Data,
              let userIdString = String(data: data, encoding: .utf8),
              let userId = UUID(uuidString: userIdString),
              let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userId })
        currentUser = try? modelContext.fetch(descriptor).first
    }

    private func deleteFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum AuthError: Error {
    case userNotFound
    case invalidPassword
    case userAlreadyExists
}
