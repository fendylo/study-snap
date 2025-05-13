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

    var id: Int { hashValue }
}


// a page to note taking, ask AI, and generate Quiz
struct NoteDetailsView: View {
    // Navigation
    @ObservedObject private var nav = NavigationUtil.shared

    // Note data & editing
    @State var note: Note
    @StateObject private var viewModel = NoteViewModel()
    @State private var newText: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @FocusState private var focusedField: Int?
    @State private var lastFocusedField: Int?
    @State private var showDeleteConfirm = false
    private let defaultMinHeight: CGFloat = 40
    @State private var didDelete = false

    // AI sheets
    @State private var activeSheet: ActiveSheet? = nil
    @State private var userQuestion: String = ""
    @State private var aiAnswer: String = ""

    // Quiz
    @StateObject private var quizViewModel = QuizViewModel()
    @State private var showQuizSuccessAlert = false
    @State private var quizSuccessMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: Title
                TextField("Note Title", text: $note.title)
                    .font(.system(size: 24, weight: .bold))
                    .padding(.horizontal)
                    .onSubmit { viewModel.update(note: note) }

                Text("Last updated: \(note.updatedAt.formatted(.dateTime.month().day().year().hour().minute()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                // MARK: Buttons
                HStack(spacing: 12) {
                    Button {
                        activeSheet = .askQuestion
                    } label: {
                        Label("Ask AI", systemImage: "sparkles")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Secondary"))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }

                    Button {
                        takeQuiz()
                    } label: {
                        Label("Take Quiz", systemImage: "list.bullet.rectangle.portrait")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Primary"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Divider()

                // MARK: Editable Content
                let contentItems = Array(note.content.enumerated())
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(contentItems, id: \.offset) { pair in
                        ContentRowView(
                            item: pair.element,
                            index: pair.offset,
                            note: $note,
                            focusedField: $focusedField,
                            lastFocusedField: $lastFocusedField,
                            defaultMinHeight: defaultMinHeight,
                            viewModel: viewModel
                        )
                    }
                }
                .padding(.horizontal)

                Divider()

                // MARK: Add Text & Image Row
                HStack(spacing: 8) {
                    PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(Color("Primary"))
                            .padding(10)
                            .background(Color("Primary").opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .onChange(of: selectedImage) { newItem in
                        if let item = newItem {
                            viewModel.uploadImageAndAdd(to: note, item: item) { updatedNote in
                                self.note = updatedNote
                            }
                        }
                    }

                    TextField("Add text...", text: $newText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: 44)

                    Button {
                        guard !newText.isEmpty else { return }
                        note.content.append(newText)
                        newText = ""
                        viewModel.update(note: note)
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    .disabled(newText.isEmpty)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
        // MARK: Navigation & Actions
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showDeleteConfirm = true } label: {
                    Image(systemName: "trash").foregroundColor(.red)
                }
            }
        }
        .alert("Delete this note?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                viewModel.delete(note: note) { success in
                    if success {
                        didDelete = true
                        nav.path.removeLast()
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .onDisappear {
            // only save if we didn’t just delete
            if !didDelete {
                viewModel.update(note: note)
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .askQuestion: askQuestionSheet
            case .showAnswer: showAnswerSheet
            }
        }
        .alert(isPresented: $showQuizSuccessAlert) {
            Alert(
                title: Text("Quiz Generation"),
                message: Text(quizSuccessMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: Ask AI Sheet
    var askQuestionSheet: some View {
        VStack(spacing: 20) {
            Text("Ask a Question").font(.headline)
            TextField("Enter your question...", text: $userQuestion)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Submit") {
                submitQuestion()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("Primary"))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    // MARK: Show Answer Sheet
    var showAnswerSheet: some View {
        VStack(spacing: 20) {
            Text("AI Answer").font(.headline)
            ScrollView {
                Text(aiAnswer)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            Button("Close") {
                activeSheet = nil
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    // MARK: Submit Question
    private func submitQuestion() {
        aiAnswer = ""
        activeSheet = .showAnswer
        viewModel.submitQuestion(for: note, userQuestion: userQuestion) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let answer): aiAnswer = answer
                case .failure(let error): aiAnswer = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: Take Quiz
    private func takeQuiz() {
        quizViewModel.generateQuiz(for: note) { result in
            DispatchQueue.main.async {
                switch result {
                case .success: quizSuccessMessage = "🎉 Quiz created! Check the Quiz tab!"
                case .failure(let error): quizSuccessMessage = "❌ Failed: \(error.localizedDescription)"
                }
                showQuizSuccessAlert = true
            }
        }
    }
}

// MARK: - Content Row Subview

struct ContentRowView: View {
    let item: String
    let index: Int

    @Binding var note: Note
    @FocusState.Binding var focusedField: Int?
    @Binding var lastFocusedField: Int?
    let defaultMinHeight: CGFloat
    let viewModel: NoteViewModel

    var body: some View {
        if item.starts(with: "http") {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: item)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                }

                Button {
                    note.content.remove(at: index)
                    viewModel.update(note: note)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .background(Color.black.opacity(0.4).clipShape(Circle()))
                }
                .padding(6)
            }
        } else {
            TextEditor(text: Binding(
                get: { note.content[index] },
                set: { note.content[index] = $0 }
            ))
            .padding(4)
            .font(.body)
            .background(Color("Secondary").opacity(0.05))
            .cornerRadius(6)
            .frame(minHeight: defaultMinHeight, maxHeight: .infinity)
            .layoutPriority(1)
            .focused($focusedField, equals: index)
            .onChange(of: focusedField) { newFocused in
                if let last = lastFocusedField, last < note.content.count {
                    let trimmed = note.content[last]
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty {
                        note.content.remove(at: last)
                    }
                    viewModel.update(note: note)
                }
                lastFocusedField = newFocused
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
