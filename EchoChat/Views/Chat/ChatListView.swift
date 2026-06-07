import SwiftUI

struct ChatListView: View {
    @Bindable var chatViewModel: ChatViewModel
    let authViewModel: AuthViewModel
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("İstifadəçilər") {
                    ForEach(chatViewModel.users) { user in
                        NavigationLink {
                            ChatView(viewModel: chatViewModel, receiver: user)
                        } label: {
                            UserRow(user: user)
                        }
                    }
                }
            }
            .navigationTitle("EchoChat")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        authViewModel.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
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
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                
                Circle()
                    .fill(user.isOnline == true ? .green : .gray)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .fontWeight(.semibold)
                
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
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ChatListView(chatViewModel: ChatViewModel(), authViewModel: AuthViewModel())
}
