import Foundation
import FirebaseAuth

struct Message: Identifiable, Codable {
    var id: String
    var senderId: String
    var receiverId: String
    var text: String
    var timestamp: Date
    var imageUrl: String?
    var isRead: Bool?
    
    var isFromCurrentUser: Bool {
        senderId == Auth.auth().currentUser?.uid
    }
    
    var isImageMessage: Bool {
        imageUrl != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id, senderId, receiverId, text, timestamp, imageUrl, isRead
    }
}
