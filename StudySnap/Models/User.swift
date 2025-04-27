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
    // Default init from FirebaseAuth.User (basic only)
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.name = firebaseUser.displayName ?? "" // Empty by default
        self.educationMajor = "" // Empty by default
    }

    // New init to init from Firestore document
    init?(documentData: [String: Any]) {
        guard
            let id = documentData["id"] as? String,
            let email = documentData["email"] as? String
        else {
            return nil
        }
        self.id = id
        self.email = email
        self.name = documentData["name"] as? String ?? ""
        self.educationMajor = documentData["educationMajor"] as? String ?? ""
    }
}
