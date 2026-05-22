import SwiftUI
import PhotosUI

struct CheckInView: View {
    let userId: UUID
    let userName: String
    let onCheckIn: (GymLocation, Data?, Bool) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var selectedGym: GymLocation?
    @State private var selectedImage: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingImageData: Data?
    @State private var checkInType: CheckInType = .photo

    enum CheckInType {
        case photo
        case locationOnly
    }

    let gymOptions = GymLocation.mockGyms()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1A")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Check-in type picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Check-in Type")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            HStack(spacing: 12) {
                                Button(action: { checkInType = .photo }) {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                        Text("Photo")
                                            .font(.caption)
                                    }
                                    .foregroundColor(checkInType == .photo ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(checkInType == .photo ? Color(hex: "4A90D9") : Color(hex: "1A1A2E"))
                                    .cornerRadius(12)
                                }

                                Button(action: { checkInType = .locationOnly }) {
                                    VStack {
                                        Image(systemName: "location.fill")
                                            .font(.title2)
                                        Text("Location Only")
                                            .font(.caption)
                                    }
                                    .foregroundColor(checkInType == .locationOnly ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(checkInType == .locationOnly ? Color(hex: "4A90D9") : Color(hex: "1A1A2E"))
                                    .cornerRadius(12)
                                }
                            }
                        }

                        // Photo section
                        if checkInType == .photo {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Add Photo")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                PhotosPicker(selection: $selectedImage, matching: .images) {
                                    if let showingImageData = showingImageData,
                                       let nsImage = NSImage(data: showingImageData) {
                                        Image(nsImage: nsImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .cornerRadius(12)
                                            .clipped()
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            .frame(height: 200)
                                            .overlay(
                                                VStack {
                                                    Image(systemName: "camera.fill")
                                                        .font(.title)
                                                        .foregroundColor(.gray)
                                                    Text("Tap to add photo")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            )
                                    }
                                }
                                .onChange(of: selectedImage) { _, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            showingImageData = data
                                            photoData = data
                                        }
                                    }
                                }
                            }
                        }

                        // Gym selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Your Gym")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            ForEach(gymOptions) { gym in
                                Button(action: { selectedGym = gym }) {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(Color(hex: "4A90D9"))

                                        Text(gym.name)
                                            .foregroundColor(.white)
                                            .font(.body)

                                        Spacer()

                                        if selectedGym?.id == gym.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color(hex: "4A90D9"))
                                        }
                                    }
                                    .padding()
                                    .background(selectedGym?.id == gym.id ? Color(hex: "2A2A3E") : Color(hex: "1A1A2E"))
                                    .cornerRadius(12)
                                }
                            }
                        }

                        // Verifying notice
                        if let gym = selectedGym {
                            HStack(spacing: 8) {
                                Image(systemName: gym.isVerified ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(gym.isVerified ? .green : .orange)

                                Text(gym.isVerified ? "Verified location" : "Unverified location (trust: \(gym.trustCount) users)")
                                    .font(.caption)
                                    .foregroundColor(gym.isVerified ? .green : .orange)
                            }
                            .padding()
                            .background(Color(hex: "1A1A2E"))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Check In")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }

                ToolbarItem(placement: .automatic) {
                    Button("Post") {
                        if let gym = selectedGym {
                            onCheckIn(gym, photoData, checkInType == .photo)
                        }
                    }
                    .foregroundColor(selectedGym != nil ? Color(hex: "4A90D9") : .gray)
                    .disabled(selectedGym == nil)
                }
            }
        }
    }
}
