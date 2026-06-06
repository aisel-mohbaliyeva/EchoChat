import Foundation

struct Chat: Identifiable, Codable {
    var id: String
    var participants: [String]
    var lastMessage: String
    var lastMessageTimestamp: Date
}
