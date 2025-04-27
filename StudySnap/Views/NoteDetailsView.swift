//
//  NoteDetailsView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI
import PhotosUI

enum ActiveSheet: Identifiable {
    case askQuestion
    case showAnswer

    var id: Int {
        hashValue
    }
}

struct NoteDetailsView: View {
    // Note functionality variables
    @State var note: Note
    @StateObject private var viewModel = NoteViewModel()
    @State private var newText: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil

    // Ask AI functionality variables
    @State private var activeSheet: ActiveSheet? = nil
    @State private var userQuestion: String = ""
    @State private var aiAnswer: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Note Title
                TextField("Note Title", text: $note.title)
                    .font(.title.bold())
                    .padding(.horizontal)
                    .onSubmit {
                        viewModel.update(note: note)
                    }

                Text("Last updated: \(note.updatedAt.formatted())")
                    .font(.caption)
                    .padding(.horizontal)

                // Ask AI Button
                Button(action: {
                    self.activeSheet = .askQuestion
                }) {
                    Label("Ask AI about this Note", systemImage: "sparkles")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Divider()

                // Display Note Content
                ForEach(note.content, id: \.self) { item in
                    if item.starts(with: "http") {
                        AsyncImage(url: URL(string: item)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Text(item)
                            .font(.body)
                            .padding(.vertical, 2)
                    }
                }

                Divider()

                // Add Text / Image Section
                VStack(spacing: 12) {
                    TextField("Add text...", text: $newText)
                        .textFieldStyle(.roundedBorder)

                    Button("Add Text") {
                        guard !newText.isEmpty else { return }
                        note.content.append(newText)
                        newText = ""
                        viewModel.update(note: note)
                    }
                    .disabled(newText.isEmpty)

                    PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                        Label("Add Image", systemImage: "photo")
                    }
                    .onChange(of: selectedImage) { newItem in
                        if let item = newItem {
                            viewModel.uploadImageAndAdd(to: note, item: item) { updatedNote in
                                self.note = updatedNote
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.update(note: note)
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .askQuestion:
                askQuestionSheet
            case .showAnswer:
                showAnswerSheet
            }
        }
    }

    // MARK: - Ask Question Sheet
    var askQuestionSheet: some View {
        VStack(spacing: 20) {
            Text("Ask a Question")
                .font(.headline)

            TextField("Enter your question...", text: $userQuestion)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Submit") {
                submitQuestion()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    // MARK: - Show Answer Sheet
    var showAnswerSheet: some View {
        VStack(spacing: 20) {
            Text("AI Answer")
                .font(.headline)

            ScrollView {
                Text(aiAnswer)
                    .padding()
                    .multilineTextAlignment(.leading)
            }

            Button("Close") {
                self.activeSheet = nil
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    func submitQuestion(){
        self.aiAnswer = ""

        viewModel.submitQuestion(for: note, userQuestion: userQuestion) { result in
            self.activeSheet = .showAnswer
            DispatchQueue.main.async {
                print("RESULT")
                print(result)
                switch result {
                case .success(let answer):
                    print(answer)
                    self.aiAnswer = answer
                case .failure(let error):
                    self.aiAnswer = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}


#Preview {
    NoteDetailsView(note: Note(
        id: UUID().uuidString,
        userId: "123",
        title: "Sample Title",
        content: ["This is a note content", "https://example.com/sample.jpg"],
        createdAt: Date(),
        updatedAt: Date()
    ))
}
