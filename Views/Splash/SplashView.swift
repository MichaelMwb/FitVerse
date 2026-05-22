import SwiftUI

struct SplashView: View {
    @Environment(AppTheme.self) var theme
    
    var body: some View {
        ZStack {
            Color(hex: "0F0F1A")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if let logoImage = UIImage(named: "SX") {
                    Image(uiImage: logoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                } else {
                    Text("SX")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4A90D9"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text("FitVerse")
                    .font(.title2)
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
        }
    }
}

#Preview {
    SplashView()
}
