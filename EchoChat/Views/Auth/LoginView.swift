//
//  LoginView.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 02.06.26.
//

import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("EchoChat")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    SecureField("Şifrə", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button {
                    Task { await viewModel.signIn() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Daxil ol")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                
                Spacer()
                
                NavigationLink {
                    RegisterView(viewModel: viewModel)
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
    LoginView(viewModel: AuthViewModel())
}
