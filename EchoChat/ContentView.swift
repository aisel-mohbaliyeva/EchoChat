//
//  ContentView.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 01.06.26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = AuthViewModel()
    
    var body: some View {
        if viewModel.isLoggedIn {
            Text("Xoş gəldin! 🎉")
        } else {
            LoginView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
