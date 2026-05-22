import SwiftUI

struct SocialView: View {
    @State private var viewModel = SocialViewModel()
    @Environment(ServiceContainer.self) var services
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1A")
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.feedItems) { post in
                                SocialPostCard(post: post)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadFeed(socialService: services.socialService)
                    }
                }
            }
            .navigationTitle("Discover")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("FitVerse")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .task {
            await viewModel.loadFeed(socialService: services.socialService)
        }
    }
}

struct SocialPostCard: View {
    let post: SocialPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4A90D9"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(post.author.prefix(1)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(post.category)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(post.content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            
            HStack(spacing: 24) {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .foregroundColor(.gray)
                        Text("\(post.likes)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("Comment")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(hex: "1A1A2E"))
        .cornerRadius(16)
    }
}
