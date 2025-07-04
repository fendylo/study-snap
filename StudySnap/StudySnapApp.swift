//
//  StudySnapApp.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct StudySnapApp: App {
    @StateObject private var authVM = AuthViewModel()
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
//        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
           StartingView()
                .environmentObject(authVM)
        }
    }
}
