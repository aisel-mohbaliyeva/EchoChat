import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
final class ChatViewModel {
    private let chatService = ChatService()
    private let userService = UserService()
    private var messagesListener: ListenerRegistration?
    private var chatsListener: ListenerRegistration?
    
    var messages: [Message] = []
    var chats: [Chat] = []
    var users: [User] = []
    var messageText = ""
    
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
    
    func stopListening() {
        messagesListener?.remove()
        chatsListener?.remove()
    }
}
