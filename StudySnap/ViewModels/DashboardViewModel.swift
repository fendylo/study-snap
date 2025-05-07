//
//  DashboardViewModel.swift
//  StudySnap
//
//  Created by Hasin Sadique on 21/4/2025.
//

//NOTE:
//Review DashboardView.swift to have ideas about the dashboard feature
//Aggregates user progress data, performance and other beneficial insights
//Used in: DashboardView


import SwiftUI
import Combine

struct TopicPerformance: Identifiable {
    let id = UUID()
    let topic: String
    let score: Double
}

struct Analytics {
    var topicPerformances: [TopicPerformance]
}

@MainActor
class DashboardViewModel: ObservableObject {

    @Published var analytics: Analytics?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchAnalytics() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Simulate fetching data from your backend or database
            // Replace this with actual data fetching logic
            try await Task.sleep(nanoseconds: 1_000_000_000) // simulate delay

            // Sample analytics data
            let sampleData = Analytics(topicPerformances: [
                TopicPerformance(topic: "Mathematics", score: 85),
                TopicPerformance(topic: "Physics", score: 78),
                TopicPerformance(topic: "Chemistry", score: 90),
                TopicPerformance(topic: "Biology", score: 72)
            ])

            // self.analytics = sampleData
            self.analytics = nil

        } catch {
            self.errorMessage = "Failed to load analytics: \(error.localizedDescription)"
        }
    }
}
