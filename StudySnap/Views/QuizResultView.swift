import SwiftUI

struct QuizResultView: View {
    let quiz: Quiz
    let selectedAnswers: [String: String]
    @ObservedObject private var nav = NavigationUtil.shared

    private var correctCount: Int {
        quiz.questions.filter { selectedAnswers[$0.id] == $0.answer }.count
    }
    private var incorrectCount: Int {
        quiz.questions.count - correctCount
    }
    private var scorePercent: Int {
        Int((Double(correctCount) / Double(quiz.questions.count)) * 100)
    }

    var body: some View {
        ZStack {
            // MARK: Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Header
                    Text("🎉 Quiz Results")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    // MARK: Score Card
                    HStack(spacing: 16) {
                        ScoreBadge(count: correctCount, label: "Correct", color: .green)
                        ScoreBadge(count: incorrectCount, label: "Incorrect", color: .red)
                        ScoreBadge(count: scorePercent, label: "% Score", color: Color("Primary"))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(16)

                    // MARK: Details
                    VStack(spacing: 16) {
                        ForEach(quiz.questions) { question in
                            ResultQuestionCard(
                                question: question,
                                selected: selectedAnswers[question.id] ?? ""
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    nav.path.removeLast()
                } label: {
                    Label("Back to Quizzes", systemImage: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: — Score Badge

struct ScoreBadge: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding(12)
        .background(color.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

// MARK: — Result Question Card

struct ResultQuestionCard: View {
    let question: QuizQuestion
    let selected: String

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
                    icon(for: choice)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor(for: choice), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(backgroundColor(for: choice))
                        )
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func icon(for choice: String) -> some View {
        if choice == question.answer {
            return Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        } else if choice == selected {
            return Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        } else {
            return Image(systemName: "circle")
                .foregroundColor(.gray)
        }
    }

    private func backgroundColor(for choice: String) -> Color {
        if choice == question.answer {
            return Color.green.opacity(0.2)
        } else if choice == selected {
            return Color.red.opacity(0.2)
        } else {
            return Color.clear
        }
    }

    private func borderColor(for choice: String) -> Color {
        if choice == question.answer {
            return .green
        } else if choice == selected {
            return .red
        } else {
            return .gray.opacity(0.4)
        }
    }
}
