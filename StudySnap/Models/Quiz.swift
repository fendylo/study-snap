//
//  Quiz.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI

struct Quiz: Identifiable, Codable {
    var id: String
    var topic: String
    var questions: [QuizQuestion]
    var score: Int
    var completedAt: Date
}

struct QuizQuestion: Identifiable, Codable {
    var id: UUID = UUID()
    let question: String
    let choices: [String]
    let answer: String
}
