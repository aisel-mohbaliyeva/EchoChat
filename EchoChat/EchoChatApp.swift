//
//  EchoChatApp.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 01.06.26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct EchoChatApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard Auth.auth().currentUser != nil else { return }
            let userService = UserService()
            Task {
                switch newPhase {
                case .active:
                    await userService.setOnlineStatus(true)
                case .inactive, .background:
                    await userService.setOnlineStatus(false)
                @unknown default:
                    break
                }
            }
        }
    }
}
