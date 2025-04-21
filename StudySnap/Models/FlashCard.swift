//
//  FlashCard.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI

struct Flashcard: Identifiable, Codable {
    var id: String
    var question: String
    var answer: String
    var topic: String
    var confidenceLevel: Int // 1–5 scale
    var isKnown: Bool
    var createdAt: Date
}
