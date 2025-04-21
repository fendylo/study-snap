//
//  User.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var displayName: String
    var profileImageURL: String?
    var joinedDate: Date
}
