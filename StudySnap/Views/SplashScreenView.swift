//
//  SplashScreenView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 3/5/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Image(.logoNoBg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.2)) {
                            self.scale = 1.0
                            self.opacity = 1.0
                        }
                    }

                Text("📚 StudySnap")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color("Primary"))
                    .opacity(opacity)
                    .animation(.easeIn(duration: 1.4), value: opacity)

                Text("AI-Powered Tools for Smarter Learning")
                    .font(.subheadline)
                    .foregroundColor(.primary.opacity(0.95)) // Brighter for readability
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(opacity)
                    .animation(.easeIn(duration: 1.5).delay(0.2), value: opacity)
                    .italic()

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SplashScreenView()
}
