//
//  QuizViewModel.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

//NOTE:
//Review QuizView.swift to have ideas about the quiz feature
//Generates quizzes
//Loads and evaluates quizzes
//Used in: QuizView, QuizDetailView, QuizResultView

import Foundation

class QuizViewModel: ObservableObject {
    
    func generateQuiz(for note: Note, completion: @escaping (Result<Void, Error>) -> Void) {
        let pureTexts = note.content.filter { !$0.lowercased().starts(with: "http") }
        let combinedText = pureTexts.joined(separator: " ")
        let wordCount = combinedText.split(separator: " ").count

        print("📄 Word count (excluding images): \(wordCount)")

        let minimumWordsThreshold = AppConstants.QUIZ_NOTE_MIN_WORD

        if wordCount < minimumWordsThreshold {
            print("⚠️ Not enough text content to generate a quiz.")
            return
        }

        let context = pureTexts.joined(separator: "\n")

        let systemPrompt = """
        You are a smart quiz generator.

        Based on the following context, you must generate:
        
        1. A **short main topic** title (e.g., "Basics of Flutter", "Photosynthesis Overview").
        2. A list of \(AppConstants.MCQ_NO) multiple choice questions with \(AppConstants.MCQ_ANSWERS) answer options each.

        Respond ONLY in this JSON format example:

        {
          "topic": "Your Generated Topic Here",
          "questions": [
            {
              "question": "What is Flutter used for?",
              "choices": ["Mobile development", "Backend", "AI research", "Embedded systems"],
              "answer": "Mobile development"
            }
          ]
        }

        Context:
        \(context)
        """

        // Now call AIService
        AIService.shared.sendRequest(systemPrompt: systemPrompt, userPrompt: "") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let content):
                    guard let quizData = content.data(using: .utf8) else {
                        print("❌ Failed to convert AI response to data")
                        return
                    }

                    do {
                        let quizResponse = try JSONDecoder().decode(GeneratedQuizResponse.self, from: quizData)
                        
                        guard let user = UserDefaultUtil.get(User.self, forKey: "currentUser") else {
                            print("❌ No logged-in user.")
                            return
                        }

                        let quiz = Quiz(
                            id: UUID().uuidString,
                            userId: user.id,
                            noteId: note.id,
                            topic: quizResponse.topic,
                            questions: quizResponse.questions,
                            createdAt: Date(),
                            completedAt: nil,
                            score: nil
                        )

                        FirebaseService.shared.setDocument(collection: "quizzes", documentId: quiz.id, data: quiz) { result in
                            switch result {
                            case .success:
                                print("✅ Quiz saved successfully to Firestore.")
                                completion(.success(()))
                            case .failure(let error):
                                print("❌ Failed to save quiz: \(error.localizedDescription)")
                                completion(.failure(error))
                            }
                        }
                        
                    } catch {
                        print("❌ Failed to decode Quiz Response: \(error.localizedDescription)")
                    }
                    
                case .failure(let error):
                    print("❌ Failed to generate quiz: \(error.localizedDescription)")
                }
            }
        }
    }
    
    struct GeneratedQuizResponse: Codable {
        var topic: String
        var questions: [QuizQuestion]
    }
}
