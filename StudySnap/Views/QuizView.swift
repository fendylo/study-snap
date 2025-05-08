import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var navigateBack = false

    var body: some View {
            VStack {
                if viewModel.quizzes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        Text("No quizzes found.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Generate a quiz from your notes to get started.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List(viewModel.quizzes) { quiz in
                        NavigationLink(destination: {
                            if let _ = quiz.completedAt {
                                QuizResultView(quiz: quiz, selectedAnswers: [:])
                            } else {
                                QuizDetailView(quiz: quiz)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(quiz.topic)
                                        .font(.headline)
                                    Text("Created: \(quiz.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: quiz.completedAt != nil ? "checkmark.seal.fill" : "clock.fill")
                                    .foregroundColor(quiz.completedAt != nil ? .green : .orange)
                            }
                        }

                    }
                    .listStyle(InsetGroupedListStyle())
                }
                NavigationLink(destination: HomeView(), isActive: $navigateBack) {
                               EmptyView()
                           }
            }
            .navigationTitle("My Quizzes")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    navigateBack = true
                                }) {
                                    Label("Back", systemImage: "chevron.left")
                                }
                            }
                        }
            .onAppear {
                viewModel.fetchQuizzes()
            }
        }
    }


