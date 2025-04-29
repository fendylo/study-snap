//
//  QuizView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct QuizView: View {
    // please use QuizViewModel.swift to store all your logic code (this file is just the UI and call the logic functions from the ViewModel)
    // this view will show a list of created quiz for this active user
    // when a particular quiz is clicked it will navigate the user to a new page to take the quiz
    // when the user clicks the quiz that they have done, it also navigates the user to quiz detail to review their past answers and the actual correct answers
    // when the user is done with the quiz, navigate to new page to show the score that the user gets
    // in summary, there will be 3 pages to handle quiz features
    var body: some View {
        Text("List of Created Quizzes")
    }
}

#Preview {
    QuizView()
}
