import Foundation

class MockSocialService: SocialService {
    func getFeed() async throws -> [SocialPost] {
        // Return placeholder content for now
        return SocialPost.placeholder()
    }
}
