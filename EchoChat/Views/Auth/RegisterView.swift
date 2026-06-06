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
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 8) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("Hesab yarat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            VStack(spacing: 16) {
                TextField("Ad və Soyad", text: $viewModel.fullName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
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
                
                SecureField("Şifrəni təsdiqlə", text: $viewModel.confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button {
                Task { await viewModel.register() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Qeydiyyatdan keç")
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
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Text("Artıq hesabın var?")
                        .foregroundStyle(.gray)
                    Text("Daxil ol")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
                .font(.footnote)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    NavigationStack {
        RegisterView(viewModel: AuthViewModel())
    }
}
