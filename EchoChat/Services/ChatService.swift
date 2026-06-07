import Foundation
import FirebaseFirestore
import FirebaseAuth

final class ChatService {
    private let db = Firestore.firestore()
    
    private var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    func sendMessage(to receiverId: String, text: String, imageUrl: String? = nil) async throws {
        let chatId = makeChatId(userId1: currentUserId, userId2: receiverId)
        
        let message = Message(
            id: UUID().uuidString,
            senderId: currentUserId,
            receiverId: receiverId,
            text: text,
            timestamp: Date(),
            imageUrl: imageUrl
        )
        
        try db.collection("chats").document(chatId)
            .collection("messages").document(message.id)
            .setData(from: message)
        
        let chatData: [String: Any] = [
            "id": chatId,
            "participants": [currentUserId, receiverId],
            "lastMessage": imageUrl != nil ? "📷 Şəkil" : text,
            "lastMessageTimestamp": Timestamp(date: Date())
        ]
        try await db.collection("chats").document(chatId).setData(chatData, merge: true)
    }
    
    func listenToMessages(chatId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, _ in
                let messages = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                } ?? []
                completion(messages)
            }
    }
    
    func listenToChats(completion: @escaping ([Chat]) -> Void) -> ListenerRegistration {
        db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { snapshot, _ in
                let chats = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Chat.self)
                } ?? []
                completion(chats.sorted { $0.lastMessageTimestamp > $1.lastMessageTimestamp })
            }
    }
    
    func setTypingStatus(_ isTyping: Bool, chatId: String) async {
        try? await db.collection("chats").document(chatId).updateData([
            "typingUserId": isTyping ? currentUserId : ""
        ])
    }
    
    func listenToTyping(chatId: String, completion: @escaping (String) -> Void) -> ListenerRegistration {
        db.collection("chats").document(chatId)
            .addSnapshotListener { snapshot, _ in
                let typingUserId = snapshot?.data()?["typingUserId"] as? String ?? ""
                completion(typingUserId)
            }
    }
    
    func markMessagesAsRead(chatId: String, receiverId: String) async {
        let snapshot = try? await db.collection("chats").document(chatId)
            .collection("messages")
            .whereField("senderId", isEqualTo: receiverId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()
        
        for doc in snapshot?.documents ?? [] {
            try? await doc.reference.updateData(["isRead": true])
        }
    }
    
    func makeChatId(userId1: String, userId2: String) -> String {
        [userId1, userId2].sorted().joined(separator: "_")
    }
}
