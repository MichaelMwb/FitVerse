import Foundation

struct Exercise: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let equipment: String
    let level: String
    let description: String
    let animationUrl: String?

    var hasAnimation: Bool {
        return animationUrl != nil && !animationUrl!.isEmpty
    }

    static func loadAll() -> [Exercise] {
        guard let url = Bundle.main.url(forResource: "custom_exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let exercises = try? JSONDecoder().decode([Exercise].self, from: data) else {
            return []
        }
        return exercises
    }

    static func loadAnimated() -> [Exercise] {
        return loadAll().filter { $0.hasAnimation }
    }
}
