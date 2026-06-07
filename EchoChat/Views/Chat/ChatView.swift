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
            
            if viewModel.isReceiverTyping {
                HStack {
                    Text("\(receiver.fullName) yazır...")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                    Spacer()
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("Mesaj yaz...", text: $viewModel.messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .onChange(of: viewModel.messageText) {
                        viewModel.setTyping(!viewModel.messageText.isEmpty, receiverId: receiver.id)
                    }
                
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
            viewModel.listenToTyping(receiverId: receiver.id)
            viewModel.markAsRead(receiverId: receiver.id)
        }
        .onDisappear {
            viewModel.setTyping(false, receiverId: receiver.id)
            viewModel.stopListening()
        }
        .onChange(of: viewModel.messages.count) {
            viewModel.markAsRead(receiverId: receiver.id)
        }

    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            
            if message.isImageMessage, let urlString = message.imageUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .cornerRadius(16)
                } placeholder: {
                    ProgressView()
                        .frame(width: 200, height: 150)
                }
            } else {
                VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                    Text(message.text)
                        .padding(12)
                        .background(message.isFromCurrentUser ? Color.blue : Color(.systemGray5))
                        .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
                        .cornerRadius(16)
                    
                    if message.isFromCurrentUser {
                        Text(message.isRead == true ? "Görüldü ✓✓" : "✓")
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)
                    }
                }
            }
            
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
