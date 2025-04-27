//
//  RegisterView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var authVM = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var educationMajor = ""
    @ObservedObject private var nav = NavigationUtil.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("StudySnap Register")
                .font(.largeTitle).bold()

            TextField("Name", text: $name).textFieldStyle(.roundedBorder)
            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            TextField("Education Major", text: $educationMajor).textFieldStyle(.roundedBorder)

            if let error = authVM.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button("Register") {
                authVM.signUp(email: email, password: password, name: name, educationMajor: educationMajor)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("Primary"))
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    RegisterView()
}
