//
//  RegisterView.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 07.06.26.
//

import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    
                    Text("Hesab yarat")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                VStack(spacing: 14) {
                    HStack {
                        Image(systemName: "person").foregroundStyle(.gray)
                        TextField("Ad və Soyad", text: $viewModel.fullName)
                    }
                    .padding()
                    .background(.white.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15)))
                    
                    HStack {
                        Image(systemName: "envelope").foregroundStyle(.gray)
                        TextField("Email", text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    .padding()
                    .background(.white.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15)))
                    
                    HStack {
                        Image(systemName: "lock").foregroundStyle(.gray)
                        SecureField("Şifrə", text: $viewModel.password)
                    }
                    .padding()
                    .background(.white.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15)))
                    
                    HStack {
                        Image(systemName: "lock.fill").foregroundStyle(.gray)
                        SecureField("Şifrəni təsdiqlə", text: $viewModel.confirmPassword)
                    }
                    .padding()
                    .background(.white.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15)))
                }
                .foregroundStyle(.white)
                .padding(.horizontal)
                
                Button {
                    Task { await viewModel.register() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                            .frame(maxWidth: .infinity).padding()
                    } else {
                        Text("Qeydiyyatdan keç")
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
                
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text("Artıq hesabın var?")
                            .foregroundStyle(.gray)
                        Text("Daxil ol")
                            .foregroundStyle(.cyan)
                            .fontWeight(.semibold)
                    }
                    .font(.footnote)
                }
            }
            .padding(.vertical)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        RegisterView(viewModel: AuthViewModel())
    }
}
