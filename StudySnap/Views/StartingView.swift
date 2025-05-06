//
//  StartingView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI


struct StartingView: View {
    @ObservedObject private var nav = NavigationUtil.shared
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack(path: $nav.path) {
//            // TODO: put splash screen here and navigate to the correct view based on the auth session status
//            if isLogged {
//                LoggedView()
//            } else {
//                LoginView()
//            }
            VStack {
                // Optional welcome/splash screen
                Image("../../Study.png")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
                Text("Welcome to StudySnap")
                    .font(.largeTitle.bold())
                    .padding()
                Text("This will be soon a splash screen")
                    .font(.caption)
                    .padding()

                Button("Continue") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if UserDefaultUtil.get(User.self, forKey: "currentUser") != nil {
//                            authVM.user = storedUser
                            nav.replaceWith(.home)
                        } else {
                            nav.replaceWith(.login)
                        }
                    }
                }
                .padding()
                .background(Color("Primary"))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .login:
                    LoginView()
                case .register:
                    RegisterView()
                case .home:
                    HomeView()
                case .noteDetails(let note):
                    NoteDetailsView(note: note)
                }
            }
        }
    }
}

struct StartingView_Previews: PreviewProvider {
    static var previews: some View {
        StartingView()
    }
}
