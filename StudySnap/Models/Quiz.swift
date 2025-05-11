//
//  Quiz.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI
import Foundation

struct Quiz: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var noteId: String
    var topic: String
    var questions: [QuizQuestion]
    var createdAt: Date
    var completedAt: Date? // Nullable: filled after user finishes quiz
    var score: Double?     // Nullable: filled after user finishes quiz
}

struct QuizQuestion: Codable, Identifiable, Hashable {
    var id: String { question } // Optional trick
    var question: String
    var choices: [String]
    var answer: String
}
