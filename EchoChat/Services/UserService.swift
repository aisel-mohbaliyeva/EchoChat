import Foundation
import FirebaseFirestore
import FirebaseAuth

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
    
    func setOnlineStatus(_ isOnline: Bool) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try? await db.collection("users").document(uid).updateData([
            "isOnline": isOnline,
            "lastSeen": FieldValue.serverTimestamp()
        ])
    }
    
    func updateProfile(fullName: String, profileImageUrl: String?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var data: [String: Any] = ["fullName": fullName]
        if let url = profileImageUrl {
            data["profileImageUrl"] = url
        }
        try await db.collection("users").document(uid).updateData(data)
    }
    
    func fetchCurrentUser() async throws -> User {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "UserService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])
        }
        return try await fetchUser(id: uid)
    }
}
