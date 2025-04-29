//
//  DashboardView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct DashboardView: View {
    // please use DashboardViewModel.swift to store all your logic code (this file is just the UI and call the logic functions from the ViewModel)
    // this page will show some charts for analytics
    // you can put any information that you think insightful for the user
    // you may use AI API call to generate the analytics based on the notes and quizzes data in our database for this active user
    // e.g.     what are the topics that are contained in the user's notes
    //          quiz performance score
    //          what things need to be improved
    //          etc.
    // this page also shows the user profile and logout button (already implemented), but the UI can be refined
    
    @EnvironmentObject var authVM: AuthViewModel
    
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
    }
}

#Preview {
    DashboardView()
}
