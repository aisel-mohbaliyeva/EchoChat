import Foundation
import FirebaseAuth

struct Message: Identifiable, Codable {
    var id: String
    var senderId: String
    var receiverId: String
    var text: String
    var timestamp: Date
    
    var isFromCurrentUser: Bool {
        senderId == Auth.auth().currentUser?.uid
    }
    
    enum CodingKeys: String, CodingKey {
        case id, senderId, receiverId, text, timestamp
    }
}
