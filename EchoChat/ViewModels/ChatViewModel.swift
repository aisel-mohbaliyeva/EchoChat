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
    var messageText = ""
    var selectedPhoto: PhotosPickerItem?
    var isSendingImage = false
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
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
    
    func stopListening() {
        messagesListener?.remove()
        chatsListener?.remove()
    }
}
