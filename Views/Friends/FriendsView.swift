import SwiftUI
import SwiftData

struct FriendsView: View {
    @State private var viewModel = FriendsViewModel()
    @Environment(AuthState.self) var authState
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1A")
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.checkIns.isEmpty {
                    ProgressView()
                        .tint(.white)
                } else if viewModel.checkIns.isEmpty {
                    emptyStateView
                } else {
                    checkInList
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("FitVerse")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showCheckInSheet = true }) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(Color(hex: "4A90D9"))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCheckInSheet) {
                if let user = authState.currentUser {
                    CheckInView(userId: user.id, userName: user.name) { gym, photoData, isPhoto in
                        viewModel.createCheckIn(
                            modelContext: modelContext,
                            userId: user.id,
                            userName: user.name,
                            gym: gym,
                            photoData: photoData,
                            isPhotoCheckIn: isPhoto
                        )
                        viewModel.showCheckInSheet = false
                    }
                }
            }
        }
        .task {
            viewModel.loadCheckIns(modelContext: modelContext)
        }
    }
    
    private var checkInList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.checkIns) { checkIn in
                    CheckInCard(checkIn: checkIn)
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.loadCheckIns(modelContext: modelContext)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Check-ins Yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Be the first to check in at your gym\!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { viewModel.showCheckInSheet = true }) {
                Text("Check In Now")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "4A90D9"), Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
}

struct CheckInCard: View {
    let checkIn: CheckIn
    
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
                        Text(String(checkIn.userName.prefix(1)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(checkIn.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text(checkIn.gymName)
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(timeAgo(checkIn.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if checkIn.isPhotoCheckIn, let photoData = checkIn.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .clipped()
            } else {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color(hex: "4A90D9"))
                    Text("At the gym")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(hex: "252538"))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(hex: "1A1A2E"))
        .cornerRadius(16)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
