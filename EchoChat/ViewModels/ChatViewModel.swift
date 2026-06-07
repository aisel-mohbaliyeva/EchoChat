import Foundation
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SwiftUI

@Observable
final class ChatViewModel {
    private let chatService = ChatService()
    private let userService = UserService()
    private let imageService = ImageService()
    private var messagesListener: ListenerRegistration?
    private var chatsListener: ListenerRegistration?
    
    var messages: [Message] = []
    var chats: [Chat] = []
    var users: [User] = []
    var allUsers: [User] = []
    var messageText = ""
    var selectedPhoto: PhotosPickerItem?
    var isSendingImage = false
    var isReceiverTyping = false
    var searchText = ""
    private var typingListener: ListenerRegistration?
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
    }
    
    func fetchUsers() async {
        do {
            users = try await userService.fetchAllUsers(except: currentUserId)
        } catch {
            print("Failed to fetch users: \(error)")
        }
    }
    
    func listenToChats() {
        chatsListener?.remove()
        chatsListener = chatService.listenToChats { [weak self] chats in
            self?.chats = chats
        }
    }
    
    func listenToMessages(receiverId: String) {
        let chatId = chatService.makeChatId(userId1: currentUserId, userId2: receiverId)
        messagesListener?.remove()
        messagesListener = chatService.listenToMessages(chatId: chatId) { [weak self] messages in
            self?.messages = messages
        }
    }
    
    func sendMessage(to receiverId: String) async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        do {
            try await chatService.sendMessage(to: receiverId, text: text)
        } catch {
            print("Failed to send message: \(error)")
        }
    }
    
    func sendImage(to receiverId: String) async {
        guard let data = await imageService.loadImage(from: selectedPhoto) else { return }
        selectedPhoto = nil
        isSendingImage = true
        do {
            let path = "chat_images/\(UUID().uuidString).jpg"
            let url = try await imageService.uploadImage(data, path: path)
            try await chatService.sendMessage(to: receiverId, text: "", imageUrl: url)
        } catch {
            print("Failed to send image: \(error)")
        }
        isSendingImage = false
    }
    
    func setTyping(_ isTyping: Bool, receiverId: String) {
        let chatId = chatService.makeChatId(userId1: currentUserId, userId2: receiverId)
        Task { await chatService.setTypingStatus(isTyping, chatId: chatId) }
    }
    
    func listenToTyping(receiverId: String) {
        let chatId = chatService.makeChatId(userId1: currentUserId, userId2: receiverId)
        typingListener?.remove()
        typingListener = chatService.listenToTyping(chatId: chatId) { [weak self] typingUserId in
            self?.isReceiverTyping = typingUserId == receiverId
        }
    }
    
    func markAsRead(receiverId: String) {
        let chatId = chatService.makeChatId(userId1: currentUserId, userId2: receiverId)
        Task { await chatService.markMessagesAsRead(chatId: chatId, receiverId: receiverId) }
    }
    
    func stopListening() {
        messagesListener?.remove()
        chatsListener?.remove()
        typingListener?.remove()
    }
}
