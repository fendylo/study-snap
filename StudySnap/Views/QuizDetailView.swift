import SwiftUI
import FirebaseFirestore


struct QuizDetailView: View {
    let quiz: Quiz
    
    // It storing answers selected by user
    @State private var selectedAnswers: [String: String] = [:]
    @State private var showResult = false

    var body: some View {
        VStack {
            Text(quiz.topic)
                .font(.largeTitle)
                .padding(.bottom)

            List {
                ForEach(quiz.questions) { question in
                    Section(header: Text(question.question)) {
                        ForEach(question.choices, id: \.self) { choice in
                            HStack {
                                Text(choice)
                                Spacer()
                                
                                // Showing checkmark icon on selected option
                                if selectedAnswers[question.id] == choice {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedAnswers[question.id] = choice
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showResult) {
                QuizResultView(quiz: quiz, selectedAnswers: selectedAnswers)
            }


            Button("Submit Quiz") {
                
                // Calculating score of quiz
                let correctCount = quiz.questions.filter { selectedAnswers[$0.id] == $0.answer }.count
                let scorePercent = Double(correctCount) / Double(quiz.questions.count)

                let updateData: [String: Any] = [
                    "score": scorePercent,
                    "completedAt": Timestamp(date: Date())
                ]

               // This service is to store data in firestore
                FirebaseService.shared.mergeDocument(
                    collection: "quizzes",
                    documentId: quiz.id,
                    data: updateData
                ) { result in
                    switch result {
                    case .success:
                        print("✅ Quiz completed. Score and date saved.")
                        showResult = true
                    case .failure(let error):
                        print("❌ Failed to update quiz result: \(error.localizedDescription)")
                    }
                }
            }
            .disabled(selectedAnswers.count != quiz.questions.count)
            .padding()

        }
        .navigationTitle("Take Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }
}
