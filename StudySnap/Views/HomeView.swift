//
//  HomeView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct HomeView: View {
    enum Tab {
        case notes
        case quiz
        case dashboard
    }

    @State private var selectedTab: Tab = .notes

    var body: some View {
        TabView(selection: $selectedTab) {
            NoteListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(Tab.notes)

            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "square.and.pencil")
                }
                .tag(Tab.quiz)

            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(Tab.dashboard)
        }
        .accentColor(Color("Primary")) // Optional: your custom theme color
    }
}

#Preview {
    HomeView()
}
