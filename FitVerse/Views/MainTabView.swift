import SwiftUI

struct MainTabView: View {
    @Environment(AuthState.self) var authState
    @State private var selectedTab = 0
    @State private var showProfileMenu = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "0F0F1A")
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                SocialView()
                    .tag(0)
                    .tabItem {
                        Image(systemName: "film")
                        Text("Social")
                    }
                
                FriendsView()
                    .tag(1)
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Friends")
                    }
                
                CoachView()
                    .tag(2)
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("Coach")
                    }
                
                GoalsView()
                    .tag(3)
                    .tabItem {
                        Image(systemName: "target")
                        Text("Goals")
                    }
            }
            .tint(Color(hex: "4A90D9"))
            
            HStack {
                Spacer()
                Button(action: { showProfileMenu = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                .padding(.top, 8)
                .padding(.trailing, 16)
            }
            .sheet(isPresented: $showProfileMenu) {
                ProfileMenuView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
