import Foundation

struct User: Identifiable, Codable {
    var id: String
    var fullName: String
    var email: String
    var profileImageUrl: String?
}
