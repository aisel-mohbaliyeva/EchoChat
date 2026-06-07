import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    let receiver: User
    @State private var showEmojiPicker = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding()
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.spring(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                if viewModel.isReceiverTyping {
                    HStack(spacing: 6) {
                        TypingIndicatorDots()
                        Text("\(receiver.fullName) yazır...")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if showEmojiPicker {
                    EmojiPickerView { emoji in
                        viewModel.messageText += emoji
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(height: 0.5)

                HStack(spacing: 10) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            showEmojiPicker.toggle()
                        }
                    } label: {
                        Image(systemName: showEmojiPicker ? "keyboard" : "face.smiling")
                            .font(.title3)
                            .foregroundStyle(.cyan)
                    }

                    TextField("Mesaj yaz...", text: $viewModel.messageText)
                        .padding(10)
                        .background(.white.opacity(0.1))
                        .foregroundStyle(.white)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.15)))
                        .onChange(of: viewModel.messageText) {
                            viewModel.setTyping(!viewModel.messageText.isEmpty, receiverId: receiver.id)
                        }
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                showEmojiPicker = false
                            }
                        }

                    Button {
                        Task { await viewModel.sendMessage(to: receiver.id) }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1.0)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(red: 0.08, green: 0.08, blue: 0.16))
            }
        }
        .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.2), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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

struct TypingIndicatorDots: View {
    @State private var dotCount = 0

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.gray)
                    .frame(width: 5, height: 5)
                    .opacity(dotCount == index ? 1.0 : 0.3)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation {
                    dotCount = (dotCount + 1) % 3
                }
            }
        }
    }
}

struct EmojiPickerView: View {
    let onSelect: (String) -> Void

    private let emojis = [
        "😀", "😂", "🥰", "😍", "😎", "🤩", "😢", "😡",
        "👍", "👎", "❤️", "🔥", "🎉", "💯", "🙏", "💪",
        "😊", "😭", "🤔", "😏", "🥺", "😴", "🤗", "🫡",
        "✨", "🌟", "💫", "⭐", "🌈", "☀️", "🌙", "💐"
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    onSelect(emoji)
                } label: {
                    Text(emoji)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.16))
    }
}

struct MessageBubble: View {
    let message: Message
    @State private var appeared = false

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
                        .tint(.cyan)
                        .frame(width: 200, height: 150)
                }
            } else {
                VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            message.isFromCurrentUser
                            ? AnyShapeStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.white.opacity(0.12))
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(18)

                    HStack(spacing: 4) {
                        Text(message.timestamp, style: .time)
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)

                        if message.isFromCurrentUser {
                            Image(systemName: message.isRead == true ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.system(size: 10))
                                .foregroundStyle(message.isRead == true ? .cyan : .gray)
                        }
                    }
                }
            }

            if !message.isFromCurrentUser { Spacer() }
        }
        .scaleEffect(appeared ? 1 : 0.5)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                appeared = true
            }
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
