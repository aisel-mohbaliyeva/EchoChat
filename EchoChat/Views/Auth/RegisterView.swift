//
//  RegisterView.swift
//  EchoChat
//
//  Created by Aysel Mohbaliyeva on 07.06.26.
//

import SwiftUI

struct RegisterView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Başlıq
            VStack(spacing: 8) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("Hesab yarat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // Input sahələri
            VStack(spacing: 16) {
                TextField("Ad və Soyad", text: $fullName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
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
                
                SecureField("Şifrəni təsdiqlə", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Register düyməsi
            Button {
                // TODO: Firebase register
            } label: {
                Text("Qeydiyyatdan keç")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Login-ə qayıtma
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
        RegisterView()
    }
}
