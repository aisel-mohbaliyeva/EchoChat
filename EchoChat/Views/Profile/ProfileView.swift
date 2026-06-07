import SwiftUI

struct ProfileView: View {
    @State private var user: User?
    @State private var fullName = ""
    @State private var isEditing = false
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss
    private let userService = UserService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.blue)
                    .padding(.top, 32)
                
                if isEditing {
                    TextField("Ad və Soyad", text: $fullName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 40)
                } else {
                    Text(user?.fullName ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text(user?.email ?? "")
                    .foregroundStyle(.gray)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(user?.isOnline == true ? .green : .gray)
                        .frame(width: 10, height: 10)
                    
                    if user?.isOnline == true {
                        Text("Online")
                            .foregroundStyle(.green)
                    } else if let lastSeen = user?.lastSeen {
                        Text("Son görülmə: \(lastSeen.formatted(.relative(presentation: .named)))")
                            .foregroundStyle(.gray)
                    }
                }
                .font(.caption)
                
                Spacer()
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Bağla") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Saxla" : "Redaktə et") {
                        if isEditing {
                            Task {
                                isSaving = true
                                try? await userService.updateProfile(fullName: fullName, profileImageUrl: nil)
                                user?.fullName = fullName
                                isEditing = false
                                isSaving = false
                            }
                        } else {
                            fullName = user?.fullName ?? ""
                            isEditing = true
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .task {
                do {
                    user = try await userService.fetchCurrentUser()
                } catch {
                    print("Failed to fetch user: \(error)")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
