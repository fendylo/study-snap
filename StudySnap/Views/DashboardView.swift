//
//  DashboardView.swift
//  StudySnap
//
//  Created by Hasin Sadique on 25/4/2025.
//

// please use DashboardViewModel.swift to store all your logic code (this file is just the UI and call the logic functions from the ViewModel)
    // this page will show some charts for analytics
    // you can put any information that you think insightful for the user
    // you may use AI API call to generate the analytics based on the notes and quizzes data in our database for this active user
    // e.g.     what are the topics that are contained in the user's notes
    //          quiz performance score
    //          what things need to be improved
    //          etc.
    // this page also shows the user profile and logout button (already implemented), but the UI can be refined

import SwiftUI
import Charts

struct DashboardView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isLoading = false
    @State private var errorMessage: String?
    @ObservedObject var dashboardVM = DashboardViewModel()
    @ObservedObject var noteVM = NoteViewModel()

    @State private var selectedNoteId: String = ""
    
    // @State private var user=authVM.user
    // @State private var isLoggedIn = authVM.user != nil
    
//    var body: some View {
//        VStack(spacing: 16) {
//            
//
//            if let user = authVM.user {
//                Text("Welcome, \(user.name)")
//                    .font(.title2)
//                Text("Major: \(user.educationMajor)")
//                    .font(.subheadline)
//            } else {
//                Text("Welcome, Guest")
//                    .font(.title2)
//                Text("Major: Not Set")
//                    .font(.subheadline)
//            }
//
//            Button("Logout") {
//                authVM.signOut()
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color("Secondary"))
//            .foregroundColor(.black)
//            .cornerRadius(8)
//        }
//        .padding()
//    }
        var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        headerSection
                        analyticsSection
                        Spacer()
                        logoutButton
                    }
                    .padding()
                }
                // .navigationTitle("Dashboard")
                .foregroundStyle(Color("Primary"))
               .task(priority: .background) {
                   await dashboardVM.fetchUserQuizzes(noteId: selectedNoteId)
                   if let user = authVM.user {
                       noteVM.fetchNotes(for: user.id)
                   }
               }
               .onChange(of: selectedNoteId) { oldValue, newValue in
                   Task {
                       await dashboardVM.fetchUserQuizzes(noteId: newValue)
                   }
               }
            }
        }
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let user = authVM.user {

                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 65))
                            .foregroundColor(Color("Primary"))
                            .padding(.trailing, 5)
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.title)
                                .bold()
                                .foregroundColor(Color("Primary"))
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Major: " + user.educationMajor)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                        .font(.subheadline)
                        .foregroundColor(.red)
                } else {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color("Primary"))
                        VStack(alignment: .leading) {
                            Text("Guest User")
                                .font(.title)
                                .bold()
                                .foregroundColor(Color("Primary"))
                            Text("guest@gmail.com")
                                .font(.subheadline)
                                .foregroundColor(Color("Primary"))
                            Text("Major: Not Set")
                                .font(.subheadline)
                                .foregroundColor(Color("Primary"))
                        }
                    }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack{
                        NavigationLink(destination: UpdateDetailsView()) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.white)
                                Text("Edit Details")
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color("Primary"))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity)
                        }
                    }
            }
            
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0))
        .shadow(radius: 3))
//        .fill(Color("CardBackground")))

    }


    
    
    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Analytics")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color("Primary"))
            }
            .padding(.bottom, 8)

            if dashboardVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let error = dashboardVM.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let analytics = dashboardVM.analytics {
                if analytics.isEmpty {
                    Text(analytics.successMessage ?? "No data available")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    if let averageResult = analytics.averageResult {
                        Text("Result: \(Int(averageResult * 100))%")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(averageResult <= 0.5 ? .red : 
                                           averageResult <= 0.65 ? .orange : 
                                           .green)
                            .padding(.bottom, 8)
                    }
                    
                    Chart(analytics.topicPerformances) { performance in
                        BarMark(
                            x: .value("Score", performance.score * 100),
                            y: .value("Topic", performance.topic)
                        )
                        .foregroundStyle(Color.accentColor)
                    }
                    .chartXAxisLabel("Scores (%)")
                    .frame(height: 250)
                    
                    if let feedback = analytics.feedback {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Feedback")
                                .font(.headline)
                                .foregroundStyle(Color("Primary"))
                            Text(feedback)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 16)
                    }
                    
                    if let message = analytics.successMessage {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    }
                }
            } else {
                Text("No quizzes available for this note")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    private var logoutButton: some View {
            // VStack {
                // Spacer()
                VStack {
                    Spacer()
                    Button(action: authVM.signOut) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .shadow(radius: 3)
                    .padding(.horizontal)
                }
            // }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthViewModel())
    }
}



//import SwiftUI
//import Charts
//
//struct DashboardView: View {
//
//    @EnvironmentObject var authVM: AuthViewModel
//    @ObservedObject var dashboardVM = DashboardViewModel()
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 20) {
//                    userHeaderSection
//                    analyticsSection
//                    logoutButton
//                }
//                .padding()
//            }
//            .navigationTitle("Dashboard")
//            .task {
//                await dashboardVM.fetchAnalytics()
//            }
//        }
//    }
//
//    private var userHeaderSection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            if let user = authVM.user {
//                Text("👋 Hi, \(user.name)!")
//                    .font(.title)
//                    .bold()
//                Text("📚 Major: \(user.educationMajor)")
//                    .font(.headline)
//                    .foregroundStyle(.secondary)
//            } else {
//                Text("👋 Hi, Guest!")
//                    .font(.title)
//                    .bold()
//                Text("📚 Major: Not Set")
//                    .font(.headline)
//                    .foregroundStyle(.secondary)
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
//        .background(.ultraThinMaterial)
//        .cornerRadius(15)
//        .shadow(radius: 5)
//    }
//
//    private var analyticsSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Your Study Analytics")
//                .font(.title2)
//                .bold()
//
//            if dashboardVM.isLoading {
//                ProgressView()
//                    .frame(maxWidth: .infinity)
//            } else if let analytics = dashboardVM.analytics {
//                Chart(analytics.topicPerformances) { performance in
//                    BarMark(
//                        x: .value("Score", performance.score),
//                        y: .value("Topic", performance.topic)
//                    )
//                    .foregroundStyle(Color.accentColor)
//                }
//                .chartXAxisLabel("Scores")
//                .frame(height: 250)
//            } else {
//                Text("No analytics available.")
//                    .foregroundStyle(.secondary)
//                    .frame(maxWidth: .infinity)
//            }
//        }
//        .padding()
//        .background(.ultraThinMaterial)
//        .cornerRadius(15)
//        .shadow(radius: 5)
//    }
//
//    private var logoutButton: some View {
//        Button(action: authVM.signOut) {
//            Label("Logout", systemImage: "arrow.backward.circle.fill")
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.red.gradient)
//                .foregroundColor(.white)
//                .cornerRadius(15)
//        }
//        .shadow(radius: 5)
//    }
//}
//
//struct DashboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        DashboardView()
//            .environmentObject(AuthViewModel())
//    }
//}

//import SwiftUI
//import Charts
//
//struct DashboardView: View {
//
//    @EnvironmentObject var authVM: AuthViewModel
//    @ObservedObject var dashboardVM = DashboardViewModel()
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 16) {
//                    headerSection
//                    analyticsSection
//                    Spacer()
//                    logoutButton
//                }
//                .padding()
//            }
//            .navigationTitle("Dashboard")
//            .task {
//                await dashboardVM.fetchAnalytics()
//            }
//            .background(
//                LinearGradient(gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                    .ignoresSafeArea()
//            )
////            .background(Color("Background").ignoresSafeArea())
//        }
//    }
//
//    private var headerSection: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                if let user = authVM.user {
//                    Text("👋 Hi, \(user.name)!")
//                        .font(.title)
//                        .bold()
//                    Text("Major: \(user.educationMajor)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                } else {
//                    HStack {
//                        Image(systemName: "person.circle.fill")
//                            .font(.system(size: 40))
//                            .foregroundColor(.gray)
//                        VStack(alignment: .leading) {
//                            Text("Guest User")
//                                .font(.title)
//                                .bold()
//                            Text("guest@gmail.com")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                            Text("Major: Not Set")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//            }
//            Spacer()
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0))
//        .shadow(radius: 3))
////        .fill(Color("CardBackground")))
//        
//    }
//
//    private var analyticsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Study Analytics")
//                .font(.headline)
//
//            if dashboardVM.isLoading {
//                ProgressView()
//                    .frame(maxWidth: .infinity)
//            } else if let analytics = dashboardVM.analytics {
//                Chart(analytics.topicPerformances) { performance in
//                    BarMark(
//                        x: .value("Score", performance.score),
//                        y: .value("Topic", performance.topic)
//                    )
//                    .foregroundStyle(Color.accentColor)
//                }
//                .chartXAxisLabel("Scores")
//                .frame(height: 220)
//            } else {
//                Text("Analytics data is not available.")
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity)
//            }
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.9)))
//        .shadow(radius: 3)
//    }
//
//    private var logoutButton: some View {
//        // VStack {
//            // Spacer()
//            Button(action: authVM.signOut) {
//                Text("Logout")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.red)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//            }
//            .shadow(radius: 3)
//            .padding(.horizontal)
//        // }
//    }
//}
//
//struct DashboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        DashboardView()
//            .environmentObject(AuthViewModel())
//    }
//}
