//
//  LoginView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject private var nav = NavigationUtil.shared

    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            // MARK: — Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: — Title
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    // MARK: — Input Fields
                    Group {
                        InputRow(icon: "envelope.fill",
                                 placeholder: "Email Address",
                                 text: $email,
                                 keyboard: .emailAddress)
                        
                        InputRow(icon: "lock.fill",
                                 placeholder: "Password",
                                 text: $password,
                                 isSecure: true)
                    }
                    .padding(.horizontal)
                    
                    // MARK: — Error Message
                    if let error = authVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // MARK: — Login Button
                    Button {
                        authVM.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                      password: password)
                    } label: {
                        HStack {
                            if authVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("Login")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)
                    
                    // MARK: — Register Link
                    HStack {
                        Text("Don’t have an account?")
                            .foregroundColor(.primary.opacity(0.9))
                            .italic()
                        Button("Register") {
                            nav.replaceWith(.register)
                        }
                        .foregroundColor(.primary)
                        .italic()
                        .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(.vertical, 40)
            }
        }
    }
}

#Preview {
    LoginView()
}
