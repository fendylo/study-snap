//
//  NavigationUtil.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

// NOTE:
// List all your page that you want to navigate in this file
// Next register your page in the StartingView, (in the navigationDestination)


import Foundation


enum AppRoute: Hashable {
    case login
    case register
    case home
    case noteDetails(note: Note)
}

class NavigationUtil: ObservableObject {
    static let shared = NavigationUtil() // Singleton

    @Published var path: [AppRoute] = []

    private init() {}

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func reset() {
        path.removeAll()
    }
    
    func replaceWith(_ route: AppRoute) {
        path = [route]
    }
}



