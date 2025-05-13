//
//  DashboardView.swift
//  StudySnap
//
//  Created by Hasin Sadique on 25/4/2025.
//


import SwiftUI
import Charts

struct DashboardView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isLoading = false
    @State private var errorMessage: String?
    @ObservedObject var dashboardVM = DashboardViewModel()
    @ObservedObject var noteVM = NoteViewModel()

    @State private var selectedNoteId: String = ""
    
    
    /// Main view body that displays the dashboard layout with gradient background
    /// Contains header, analytics, and logout sections
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack{
                
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                    Text("Dashboard")
                }
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
            
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
    }

    /// Displays user profile information and edit details button
    /// Shows user name, email, major, and profile picture
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


    
    
    /// Shows analytics data including quiz performance charts and AI feedback
    /// Displays loading state, error messages, and performance metrics
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

    /// Logout button that triggers user sign out
    /// Styled with red background and white text
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


