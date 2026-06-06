import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    let receiver: User
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("Mesaj yaz...", text: $viewModel.messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button {
                    Task { await viewModel.sendMessage(to: receiver.id) }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(receiver.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.listenToMessages(receiverId: receiver.id)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            
            Text(message.text)
                .padding(12)
                .background(message.isFromCurrentUser ? Color.blue : Color(.systemGray5))
                .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
                .cornerRadius(16)
            
            if !message.isFromCurrentUser { Spacer() }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(
            viewModel: ChatViewModel(),
            receiver: User(id: "1", fullName: "Test User", email: "test@test.com")
        )
    }
}
