//
//  LoginView.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 02.06.26.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // App logo və adı
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("EchoChat")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                // Input sahələri
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    SecureField("Şifrə", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Login düyməsi
                Button {
                    // TODO: Firebase login
                } label: {
                    Text("Daxil ol")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Register-ə keçid
                NavigationLink {
                    RegisterView()
                } label: {
                    HStack(spacing: 4) {
                        Text("Hesabın yoxdur?")
                            .foregroundStyle(.gray)
                        Text("Qeydiyyatdan keç")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                    .font(.footnote)
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    LoginView()
}
