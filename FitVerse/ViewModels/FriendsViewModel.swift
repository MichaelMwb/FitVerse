import Foundation
import SwiftUI
import SwiftData

@Observable
class FriendsViewModel {
    var checkIns: [CheckIn] = []
    var isLoading: Bool = false
    var showCheckInSheet: Bool = false
    
    func loadCheckIns(modelContext: ModelContext) {
        isLoading = true
        defer { isLoading = false }
        
        let descriptor = FetchDescriptor<CheckIn>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            checkIns = try modelContext.fetch(descriptor)
        } catch {
            checkIns = []
        }
    }
    
    func createCheckIn(modelContext: ModelContext, userId: UUID, userName: String, gym: GymLocation, photoData: Data?, isPhotoCheckIn: Bool) {
        let checkIn = CheckIn(
            userId: userId,
            photoData: photoData,
            gymName: gym.name,
            gymLatitude: gym.latitude,
            gymLongitude: gym.longitude,
            isPhotoCheckIn: isPhotoCheckIn,
            userName: userName
        )
        
        modelContext.insert(checkIn)
        try? modelContext.save()
        loadCheckIns(modelContext: modelContext)
    }
}
