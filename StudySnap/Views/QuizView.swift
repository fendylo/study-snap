import SwiftUI

struct QuizView: View {
    @ObservedObject private var nav = NavigationUtil.shared
    @StateObject private var viewModel = QuizViewModel()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // Custom nav bar
                HStack {
                    Text("📄 My Quizzes")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button { viewModel.fetchQuizzes() } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                if viewModel.quizzes.isEmpty {
                    Spacer()
                    // Empty-state view
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white.opacity(0.7))
                        Text("No quizzes yet")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        Text("Generate a quiz from your notes to get started.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    // Quiz cards
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.quizzes) { quiz in
                                QuizCardView(quiz: quiz)
                                    .onTapGesture {
                                        if quiz.completedAt != nil {
                                            nav.navigate(to: .quizResult(quiz: quiz, selectedAnswers: [:]))
                                        } else {
                                            nav.navigate(to: .quizDetail(quiz: quiz))
                                        }
                                    }
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .onAppear { viewModel.fetchQuizzes() }
    }
}

// MARK: — Quiz Card

struct QuizCardView: View {
    let quiz: Quiz

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(quiz.topic)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(quiz.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: quiz.completedAt != nil ? "checkmark.seal.fill" : "clock.fill")
                .font(.title2)
                .foregroundColor(quiz.completedAt != nil ? .green : Color("Primary"))
        }
        .padding()
        .background(Color("Secondary").opacity(0.2))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}
