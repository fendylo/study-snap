//
//  AuthViewModel.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

//NOTE:
//Firebase Auth sign-in/sign-up/sign-out
//
//Tracks session state and current user
//
//Used in: LoginView, RegisterView, ProfileView


import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let navigator = NavigationUtil.shared

    init() {
        fetchCurrentUser()
    }

    func fetchCurrentUser() {
        FirebaseService.shared.getCurrentUser { [weak self] user in
            DispatchQueue.main.async {
                self?.user = user
                if user != nil {
                    self?.navigator.replaceWith(.home)
                }
            }
        }
    }

    func signUp(email: String, password: String, name: String, educationMajor: String) {
        isLoading = true
        FirebaseService.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                    case .success(let baseUser):
                        var newUser = baseUser
                        newUser.name = name
                        newUser.educationMajor = educationMajor
                        self?.user = newUser
                        UserDefaultUtil.set(newUser, forKey: "currentUser")
                        
                        // ✅ Use generic setDocument to insert user to Firestore
                        FirebaseService.shared.setDocument(
                            collection: "users",
                            documentId: newUser.id,
                            data: newUser
                        ) { result in
                            switch result {
                                case .success():
                                    print("✅ User inserted using setDocument")
                                case .failure(let error):
                                    print("❌ Failed to insert user: \(error.localizedDescription)")
                                }
                        }
                        self?.navigator.replaceWith(.home)
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        isLoading = true
        FirebaseService.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let loggedUser):
                    print("LOGIN SUCCESSFUL")
                    print(loggedUser)
                    self?.user = loggedUser
                    UserDefaultUtil.set(loggedUser, forKey: "currentUser")
                    self?.navigator.replaceWith(.home)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signOut() {
        do {
            try FirebaseService.shared.signOut()
            self.user = nil
            UserDefaultUtil.remove(forKey: "currentUser")
            navigator.replaceWith(.login)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
