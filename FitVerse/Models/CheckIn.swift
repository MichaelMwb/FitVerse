import Foundation
import SwiftData

@Model
final class CheckIn {
    var id: UUID
    var userId: UUID
    var date: Date
    var photoData: Data?
    var gymName: String
    var gymLatitude: Double
    var gymLongitude: Double
    var isPhotoCheckIn: Bool
    var userName: String

    init(
        id: UUID = UUID(),
        userId: UUID,
        date: Date = Date(),
        photoData: Data? = nil,
        gymName: String = "",
        gymLatitude: Double = 0,
        gymLongitude: Double = 0,
        isPhotoCheckIn: Bool = false,
        userName: String = ""
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.photoData = photoData
        self.gymName = gymName
        self.gymLatitude = gymLatitude
        self.gymLongitude = gymLongitude
        self.isPhotoCheckIn = isPhotoCheckIn
        self.userName = userName
    }
}

struct GymLocation: Identifiable, Codable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let trustCount: Int
    let isVerified: Bool

    static func mockGyms() -> [GymLocation] {
        [
            GymLocation(id: UUID(), name: "Gold's Gym Venice", latitude: 33.9850, longitude: -118.4695, trustCount: 150, isVerified: true),
            GymLocation(id: UUID(), name: "LA Fitness - Downtown", latitude: 34.0407, longitude: -118.2468, trustCount: 89, isVerified: true),
            GymLocation(id: UUID(), name: "24 Hour Fitness - Midtown", latitude: 34.0195, longitude: -118.4912, trustCount: 45, isVerified: true),
            GymLocation(id: UUID(), name: "Planet Fitness - Westside", latitude: 34.0293, longitude: -118.3872, trustCount: 67, isVerified: true),
            GymLocation(id: UUID(), name: "Equinox - Century City", latitude: 34.0580, longitude: -118.4170, trustCount: 120, isVerified: true)
        ]
    }
}
