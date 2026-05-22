import SwiftUI

enum AppTheme {
    case male
    case female
    case other

    var primaryGradient: LinearGradient {
        switch self {
        case .male:
            LinearGradient(
                colors: [Color(hex: "4A90D9"), Color(hex: "2E5A88")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .female:
            LinearGradient(
                colors: [Color(hex: "8B5CF6"), Color(hex: "6D28D9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .other:
            LinearGradient(
                colors: [Color(hex: "6366F1"), Color(hex: "4F46E5")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var accentColor: Color {
        switch self {
        case .male:
            Color(hex: "2563EB")
        case .female:
            Color(hex: "9333EA")
        case .other:
            Color(hex: "7C3AED")
        }
    }

    var backgroundColor: Color {
        Color(hex: "0F0F1A")
    }

    var cardBackgroundColor: Color {
        Color(hex: "1A1A2E")
    }

    var textColor: Color {
        .white
    }

    var secondaryTextColor: Color {
        Color(hex: "9CA3AF")
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
