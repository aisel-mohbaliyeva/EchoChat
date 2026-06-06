import Foundation
import FirebaseFirestore

final class UserService {
    private let db = Firestore.firestore()
    
    func saveUser(_ user: User) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    func fetchUser(id: String) async throws -> User {
        let document = try await db.collection("users").document(id).getDocument()
        return try document.data(as: User.self)
    }
    
    func fetchAllUsers(except currentUserId: String) async throws -> [User] {
        let snapshot = try await db.collection("users").getDocuments()
        return snapshot.documents.compactMap { doc in
            let user = try? doc.data(as: User.self)
            return user?.id == currentUserId ? nil : user
        }
    }
}
