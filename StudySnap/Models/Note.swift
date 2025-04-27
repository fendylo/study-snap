//
//  Note.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI
import Foundation

struct Note: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var title: String
    var content: [String]
    var createdAt: Date
    var updatedAt: Date
}
