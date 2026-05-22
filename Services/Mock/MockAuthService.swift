import Foundation
import SwiftData
import Security
import CryptoKit

class MockAuthService: AuthService {
    private var currentUser: User?
    private let modelContext: ModelContext?

    private let keychainKey = "fitverse_current_user_id"

    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
        loadCurrentUser()
    }

    func signUp(name: String, email: String, password: String) async throws -> User {
        guard let modelContext else { throw AuthError.internalError }

        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
        let existing = try modelContext.fetch(descriptor)
        if !existing.isEmpty { throw AuthError.userAlreadyExists }

        let salt = UUID().uuidString
        let hash = hashPassword(password, salt: salt)

        let user = User(
            name: name,
            email: email,
            passwordHash: "\(salt):\(hash)",
            createdAt: Date()
        )

        modelContext.insert(user)
        try modelContext.save()

        currentUser = user
        saveToKeychain(userId: user.id)

        return user
    }

    func signIn(email: String, password: String) async throws -> User {
        guard let modelContext else { throw AuthError.internalError }

        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
        let users = try modelContext.fetch(descriptor)
        guard let user = users.first else { throw AuthError.userNotFound }

        let parts = user.passwordHash.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { throw AuthError.invalidPassword }
        let salt = String(parts[0])
        let storedHash = String(parts[1])

        guard hashPassword(password, salt: salt) == storedHash else {
            throw AuthError.invalidPassword
        }

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

    // SHA-256 with salt. Replace with bcrypt/Argon2 on the real backend.
    private func hashPassword(_ password: String, salt: String) -> String {
        let combined = Data((salt + password).utf8)
        let digest = SHA256.hash(data: combined)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
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

enum AuthError: Error, LocalizedError {
    case userNotFound
    case invalidPassword
    case userAlreadyExists
    case internalError

    var errorDescription: String? {
        switch self {
        case .userNotFound: return "No account found with that email."
        case .invalidPassword: return "Incorrect password."
        case .userAlreadyExists: return "An account with that email already exists."
        case .internalError: return "An internal error occurred. Please try again."
        }
    }
}
