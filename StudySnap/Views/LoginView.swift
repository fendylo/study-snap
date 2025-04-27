//
//  LoginView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @ObservedObject private var nav = NavigationUtil.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("StudySnap Login")
                .font(.largeTitle).bold()

            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)

            if let error = authVM.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button("Login") {
                authVM.signIn(email: email, password: password)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("Primary"))
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Don't have an account? Register") {
                nav.navigate(to: .register)
            }
            .font(.footnote)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
