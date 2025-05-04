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
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                NavigationStack(path: $nav.path) {
                    VStack(spacing: 24) {
                        Spacer()

                        VStack(spacing: 12) {
                            Image(.logoNoBg)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .shadow(radius: 10)

                            Text("Welcome to")
                                .font(.headline)
                                .foregroundColor(.gray)

                            Text("📚 StudySnap")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color("Primary"))
                                .multilineTextAlignment(.center)

                            Text("Are you ready to learn something new today?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .italic()
                        }

                        

                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let storedUser = UserDefaultUtil.get(User.self, forKey: "currentUser") {
                                    nav.replaceWith(.home)
                                } else {
                                    nav.replaceWith(.login)
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                Text("Continue")
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Primary"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea()
                    )
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.showSplash = false
                }
            }
        }
    }
}

#Preview {
    StartingView()
}
