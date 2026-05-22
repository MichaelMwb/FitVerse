import Foundation
import SwiftData

class MockUserService: UserService {
    private let modelContext: ModelContext?

    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
    }

    func getUser(id: UUID) async throws -> User? {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == id })
        return try modelContext?.fetch(descriptor).first
    }

    func updateUser(_ user: User) async throws -> User {
        try modelContext?.save()
        return user
    }

    func updateWeight(userId: UUID, weight: Double) async throws {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userId })
        guard let user = try modelContext?.fetch(descriptor).first else { return }
        user.weight = weight
        try modelContext?.save()
    }
}
