import SwiftUI

struct ProfileView: View {
    @State private var user: User?
    @State private var fullName = ""
    @State private var isEditing = false
    @State private var isSaving = false
    @State private var avatarScale = 0.5
    @Environment(\.dismiss) private var dismiss
    private let userService = UserService()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .scaleEffect(avatarScale)
                        .padding(.top, 40)

                    if isEditing {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundStyle(.gray)
                            TextField("Ad və Soyad", text: $fullName)
                        }
                        .padding()
                        .background(.white.opacity(0.1))
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15)))
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Text(user?.fullName ?? "")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }

                    Text(user?.email ?? "")
                        .foregroundStyle(.gray)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(user?.isOnline == true ? .green : .gray.opacity(0.5))
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
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.2), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Bağla") { dismiss() }
                        .foregroundStyle(.cyan)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Saxla" : "Redaktə et") {
                        if isEditing {
                            Task {
                                isSaving = true
                                try? await userService.updateProfile(fullName: fullName, profileImageUrl: nil)
                                user?.fullName = fullName
                                withAnimation(.spring(duration: 0.3)) {
                                    isEditing = false
                                }
                                isSaving = false
                            }
                        } else {
                            fullName = user?.fullName ?? ""
                            withAnimation(.spring(duration: 0.3)) {
                                isEditing = true
                            }
                        }
                    }
                    .foregroundStyle(.cyan)
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
            .onAppear {
                withAnimation(.spring(duration: 0.6)) {
                    avatarScale = 1.0
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
