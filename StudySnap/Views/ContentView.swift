//
//  ContentView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

import SwiftUI
import SwiftDotenv

struct ContentView: View {
    @StateObject private var viewModel = GroqViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter your prompt...", text: $viewModel.prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    viewModel.sendPrompt()
                }) {
                    Text("Send to Groq")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    ScrollView {
                        Text(viewModel.responseText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()
            }
            .navigationTitle("StudySnap AI")
        }
    }
}


#Preview {
    ContentView()
}
