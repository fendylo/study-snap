//
//  Quiz.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI

struct Quiz: Identifiable, Codable {
    var id: String
    var userId: String
    var noteId: String
    var topic: String
    var questions: [QuizQuestion]
    var createdAt: Date
    var completedAt: Date? // Nullable: filled after user finishes quiz
    var score: Double?     // Nullable: filled after user finishes quiz
}

struct QuizQuestion: Codable, Identifiable {
    var id: String { question } // Optional trick
    var question: String
    var choices: [String]
    var answer: String
}
