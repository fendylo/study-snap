import SwiftUI
import FirebaseFirestore

struct QuizResultView: View {
    let quiz: Quiz
    let selectedAnswers: [String: String]
    @Environment(\.dismiss) private var dismiss
    @State private var navigateBack = false
    
    
    var score: Int {
        quiz.questions.filter { selectedAnswers[$0.id] == $0.answer }.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Quiz Result")
                .font(.largeTitle.bold())
            
            Text("✅ \(score) Correct   ❌ \(quiz.questions.count - score) Incorrect")
                .font(.title3)
                .foregroundColor(.primary)
            
            List(quiz.questions, id: \.question) { q in
                VStack(alignment: .leading, spacing: 8) {
                    Text(q.question)
                        .font(.headline)
                    
                    ForEach(q.choices, id: \.self) { choice in
                        HStack {
                            Text("• \(choice)")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedAnswers[q.id] == choice {
                                if choice == q.answer {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            } else if choice == q.answer {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            NavigationLink(destination: QuizView(), isActive: $navigateBack) {
                           EmptyView()
                       }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back to Quizzes") {
                    navigateBack = true
                }
            }
        }
        
    }
}
