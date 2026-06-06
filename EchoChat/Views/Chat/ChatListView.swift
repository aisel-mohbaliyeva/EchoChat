import SwiftUI

struct ChatListView: View {
    @Bindable var chatViewModel: ChatViewModel
    let authViewModel: AuthViewModel
    
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        authViewModel.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
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
            Image(systemName: "person.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .fontWeight(.semibold)
                Text(user.email)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ChatListView(chatViewModel: ChatViewModel(), authViewModel: AuthViewModel())
}
