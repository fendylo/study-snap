//
//  RegisterView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject private var nav = NavigationUtil.shared
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var educationMajor = ""
    
    // For button press animation
    @State private var isRegistering = false
    
    var body: some View {
        ZStack {
            // MARK: — Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("Secondary"),
                    Color("Tertiary")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: — Title
                    
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    // MARK: — Input Fields
                    Group {
                        InputRow(icon: "person.fill", placeholder: "Full Name", text: $name)
                        InputRow(icon: "envelope.fill", placeholder: "Email Address", text: $email, keyboard: .emailAddress)
                        InputRow(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                        InputRow(icon: "graduationcap.fill", placeholder: "Education Major", text: $educationMajor)
                    }
                    .padding(.horizontal)
                    
                    // MARK: — Error Message
                    if let error = authVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // MARK: — Register Button
                    Button {
                        withAnimation(.spring()) {
                            isRegistering = true
                        }
                        authVM.signUp(
                            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                            password: password,
                            name: name,
                            educationMajor: educationMajor
                        )
                    } label: {
                        HStack {
                            if isRegistering {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("Register")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .disabled([name, email, password, educationMajor].contains(where: \.isEmpty))
                    .scaleEffect(isRegistering ? 0.95 : 1)
                    .animation(.easeOut(duration: 0.2), value: isRegistering)
                    
                    // MARK: — Footer Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.primary.opacity(0.9))
                            .italic()
                        Button("Sign In") {
                            nav.replaceWith(.login)
                        }
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                        .italic()
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
    RegisterView()
}
