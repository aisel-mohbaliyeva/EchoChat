//
//  AuthService.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 07.06.26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
final class AuthService {
    var user: FirebaseAuth.User?
    var isLoggedIn: Bool { user != nil }
    var errorMessage = ""
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    func signIn(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func register(email: String, password: String, fullName: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            
            let newUser = User(
                id: result.user.uid,
                fullName: fullName,
                email: email,
                profileImageUrl: nil
            )
            try Firestore.firestore().collection("users").document(newUser.id).setData(from: newUser)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
