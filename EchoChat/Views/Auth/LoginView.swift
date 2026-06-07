//
//  LoginView.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 02.06.26.
//

import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    @State private var logoScale = 0.5
    @State private var logoOpacity = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 36) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                        
                        Text("EchoChat")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("Söhbətə başla")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .transition(.opacity)
                    }
                    
                    VStack(spacing: 14) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundStyle(.gray)
                            TextField("Email", text: $viewModel.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .background(.white.opacity(0.1))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15)))
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundStyle(.gray)
                            SecureField("Şifrə", text: $viewModel.password)
                        }
                        .padding()
                        .background(.white.opacity(0.1))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15)))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    
                    Button {
                        Task { await viewModel.signIn() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                                .frame(maxWidth: .infinity).padding()
                        } else {
                            Text("Daxil ol")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity).padding()
                        }
                    }
                    .background(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundStyle(.white)
                    .cornerRadius(14)
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
                                .foregroundStyle(.cyan)
                                .fontWeight(.semibold)
                        }
                        .font(.footnote)
                    }
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
