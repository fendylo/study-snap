//
//  DashboardView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var authVM = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            if let user = authVM.user {
                Text("Welcome, \(user.name)")
                    .font(.title2)
                Text("Major: \(user.educationMajor)")
                    .font(.subheadline)
            }

            Button("Logout") {
                authVM.signOut()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("Secondary"))
            .foregroundColor(.black)
            .cornerRadius(8)
        }
        .padding()
        .onAppear {
            if let storedUser = UserDefaultUtil.get(User.self, forKey: "currentUser") {
                authVM.user = storedUser
            }
        }
    }
}

#Preview {
    DashboardView()
}
