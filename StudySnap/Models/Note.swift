//
//  Note.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI

struct Note: Identifiable, Codable {
    var id: String
    var title: String
    var content: String
    var imageURL: String?
    var userId: String
    var createdAt: Date
}
