import SwiftUI

struct ChatListView: View {
    @Bindable var chatViewModel: ChatViewModel
    let authViewModel: AuthViewModel
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(chatViewModel.filteredUsers) { user in
                            NavigationLink {
                                ChatView(viewModel: chatViewModel, receiver: user)
                            } label: {
                                UserRow(user: user)
                            }

                            Rectangle()
                                .fill(.white.opacity(0.06))
                                .frame(height: 0.5)
                                .padding(.leading, 70)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("EchoChat")
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.2), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $chatViewModel.searchText, prompt: "İstifadəçi axtar...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.cyan)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        authViewModel.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.cyan)
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .task {
                await chatViewModel.fetchUsers()
                chatViewModel.listenToChats()
            }
        }
    }
}

struct UserRow: View {
    let user: User
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Circle()
                    .fill(user.isOnline == true ? .green : .gray.opacity(0.5))
                    .frame(width: 13, height: 13)
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.1, green: 0.1, blue: 0.2), lineWidth: 2.5)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                if user.isOnline == true {
                    Text("Online")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else if let lastSeen = user.lastSeen {
                    Text("Son: \(lastSeen.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.gray)
                } else {
                    Text(user.email)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                appeared = true
            }
        }
    }
}

#Preview {
    ChatListView(chatViewModel: ChatViewModel(), authViewModel: AuthViewModel())
}
