//
//  ContentView.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 01.06.26.
//

import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var chatViewModel = ChatViewModel()
    
    var body: some View {
        if authViewModel.isLoggedIn {
            ChatListView(chatViewModel: chatViewModel, authViewModel: authViewModel)
        } else {
            LoginView(viewModel: authViewModel)
        }
    }
}

#Preview {
    ContentView()
}
