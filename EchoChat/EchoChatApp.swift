//
//  EchoChatApp.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 01.06.26.
//

import SwiftUI
import FirebaseCore

@main
struct EchoChatApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
