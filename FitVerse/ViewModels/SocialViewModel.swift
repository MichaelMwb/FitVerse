import Foundation
import SwiftUI

@Observable
class SocialViewModel {
    var feedItems: [SocialPost] = []
    var isLoading: Bool = false
    
    func loadFeed(socialService: SocialService) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            feedItems = try await socialService.getFeed()
        } catch {
            feedItems = SocialPost.placeholder()
        }
    }
}
