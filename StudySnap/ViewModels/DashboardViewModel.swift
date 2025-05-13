//
//  DashboardViewModel.swift
//  StudySnap
//
//  Created by Hasin Sadique on 21/4/2025.
//


import SwiftUI
import Combine

struct TopicPerformance: Identifiable {
    let id = UUID()
    let topic: String
    let score: Double
}

struct Analytics: Identifiable {
    let id = UUID()
    var topicPerformances: [TopicPerformance]
    var successMessage: String?
    var isEmpty: Bool
    var averageResult: Double?
    var feedback: String?
}

@MainActor
class DashboardViewModel: ObservableObject {

    @Published var analytics: Analytics?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    /// Fetches and processes quiz data for analytics visualization
    /// Parameter noteId: Optional note ID to filter quizzes for a specific note
    /// Returns: Updates analytics property with processed quiz data and AI feedback
    func fetchUserQuizzes(noteId: String) async {
        guard let user = UserDefaultUtil.get(User.self, forKey: "currentUser") else {
            self.errorMessage = "No logged-in user found. Please log in again."
            return
        }

        isLoading = true
        defer { isLoading = false }

        let filters: [[String: Any]] = noteId.isEmpty ? 
            [["userId": user.id]] : 
            [["userId": user.id, "noteId": noteId]]
            
        FirebaseService.shared.getCollection(
            collection: "quizzes",
            model: Quiz.self,
            filters: filters
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let quizzes):
                    print("✅ Successfully fetched \(quizzes.count) quizzes")
                    
                    if quizzes.isEmpty {
                        if noteId.isEmpty {
                            self.analytics = Analytics(
                                topicPerformances: [],
                                successMessage: "No quizzes found. Start taking quizzes to see your progress!",
                                isEmpty: true,
                                averageResult: nil,
                                feedback: nil
                            )
                        } else {
                            self.analytics = Analytics(
                                topicPerformances: [],
                                successMessage: "No quizzes found for this note.",
                                isEmpty: true,
                                averageResult: nil,
                                feedback: nil
                            )
                        }
                        return
                    }
                    
                    // Process quizzes to create analytics
                    let topicScores = Dictionary(grouping: quizzes) { $0.topic }
                        .mapValues { quizzes -> Double in
                            let validScores = quizzes.compactMap { $0.score }
                            return validScores.isEmpty ? 0 : validScores.reduce(0, +) / Double(validScores.count)
                        }
                    
                    // Calculate overall average
                    let allScores = quizzes.compactMap { $0.score }
                    let averageResult = allScores.isEmpty ? 0 : allScores.reduce(0, +) / Double(allScores.count)
                    
                    // Sort topics by score for better visualization
                    let performances = topicScores
                        .map { TopicPerformance(topic: $0.key, score: $0.value) }
                        .sorted { $0.score > $1.score }
                    
                    let successMessage = noteId.isEmpty ? 
                        "Well done! Here's your overall performance." : 
                        "Here's your performance for this note."
                    
                    // Get AI feedback
                    self.getAIFeedback(averageScore: averageResult) { feedback in
                        self.analytics = Analytics(
                            topicPerformances: performances,
                            successMessage: successMessage,
                            isEmpty: false,
                            averageResult: averageResult,
                            feedback: feedback
                        )
                    }
                    
                    print("✅ Loaded analytics from \(quizzes.count) quizzes")
                    
                case .failure(let error):
                    print("❌ Error fetching quizzes: \(error.localizedDescription)")
                    self.errorMessage = "Failed to load analytics: \(error.localizedDescription)"
                }
            }
        }
    }

    // Generates AI-powered feedback based on user's quiz performance
    // Parameter averageScore: The user's average quiz score
    //  Parameter completion: Callback with the generated feedback message
    private func getAIFeedback(averageScore: Double, completion: @escaping (String) -> Void) {
        let systemPrompt = "You are a helpful educational assistant. Provide brief, encouraging feedback based on the student's quiz performance."
        let userPrompt = "The student has an average quiz score of \(Int(averageScore * 100))%. Please provide a brief, analytical feedback message (2-3 sentences maximum). Suggest how to improve if average score is below 50%"
        
        AIService.shared.sendRequest(systemPrompt: systemPrompt, userPrompt: userPrompt) { result in
            switch result {
            case .success(let feedback):
                completion(feedback)
            case .failure(let error):
                print("❌ Error getting AI feedback: \(error.localizedDescription)")
                completion("Keep up the good work! Continue practicing to improve your scores.")
            }
        }
    }

    /// Retrieves all notes associated with the current user
    /// Returns: Updates the view model with fetched notes data
    func fetchUserNotes() async {
        guard let user = UserDefaultUtil.get(User.self, forKey: "currentUser") else {
            print("❌ No logged-in user.")
            return
        }

        FirebaseService.shared.getCollection(
            collection: "notes",
            model: Note.self,
            filters: [["userId": user.id]]
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let notes):
                    print("✅ Successfully fetched \(notes.count) notes")
                    // Process notes as needed
                    
                case .failure(let error):
                    print("❌ Error fetching notes: \(error.localizedDescription)")
                    self.errorMessage = "Failed to load notes: \(error.localizedDescription)"
                }
            }
        }
    }

    

    

}
