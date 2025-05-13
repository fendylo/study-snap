import SwiftUI
import FirebaseFirestore


// Quiz Taking Page
struct QuizDetailView: View {
    let quiz: Quiz
    @State private var selectedAnswers: [String: String] = [:]
    @State private var showResult = false

    var body: some View {
        ZStack {
            // MARK: — Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // MARK: — Title
                Text(quiz.topic)
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.top, 16)

                // MARK: — Questions
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(quiz.questions) { question in
                            QuestionCard(
                                question: question,
                                selected: selectedAnswers[question.id]
                            ) { choice in
                                selectedAnswers[question.id] = choice
                            }
                        }
                    }
                    .padding()
                }

                Spacer()

                // MARK: — Submit Button
                Button(action: submit) {
                    Text("Submit Quiz")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedAnswers.count == quiz.questions.count
                                    ? Color("Primary")
                                    : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .disabled(selectedAnswers.count != quiz.questions.count)
                .padding(.horizontal)
                .padding(.bottom, 16)

                // Invisible NavigationLink to results
                NavigationLink("", destination: QuizResultView(quiz: quiz, selectedAnswers: selectedAnswers), isActive: $showResult)
                    .hidden()
            }
        }
        .navigationTitle("Take Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() {
        let correctCount = quiz.questions.filter { selectedAnswers[$0.id] == $0.answer }.count
        let scorePercent = Double(correctCount) / Double(quiz.questions.count)

        let updateData: [String: Any] = [
            "score": scorePercent,
            "completedAt": Timestamp(date: Date())
        ]

        FirebaseService.shared.mergeDocument(
            collection: "quizzes",
            documentId: quiz.id,
            data: updateData
        ) { result in
            switch result {
            case .success:
                showResult = true
            case .failure(let error):
                print("Failed to update quiz result: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: — Question Card

struct QuestionCard: View {
    let question: QuizQuestion
    let selected: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question)
                .font(.headline)
                .foregroundColor(.primary)

            ForEach(question.choices, id: \.self) { choice in
                HStack {
                    Text(choice)
                        .foregroundColor(.primary)
                    Spacer()
                    if selected == choice {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("Primary"))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selected == choice
                              ? Color("Primary").opacity(0.2)
                              : Color("Secondary").opacity(0.1))
                )
                .onTapGesture { onSelect(choice) }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
