import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var userId: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        content: String,
        isFromUser: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}
