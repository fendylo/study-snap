//
//  StudySnapApp.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI
import SwiftDotenv



@main
struct StudySnapApp: App {
    init() {
        // load in environment variables
        do {
            try Dotenv.configure()
        } catch {
            print("⚠️ Failed to load .env file: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
