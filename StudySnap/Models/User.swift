//
//  User.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI
import FirebaseAuth

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var name: String
    var educationMajor: String
}

extension User {
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.name = firebaseUser.displayName ?? "New User"
        self.educationMajor = "" // default or fetched later
    }
}
