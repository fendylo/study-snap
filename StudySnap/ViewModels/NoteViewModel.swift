//
//  NoteViewModel.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//



//NOTE:
//Upload typed or image-based notes
//
//Ask AI to summarize or highlight
//
//Interacts with AIService and FirebaseService
//
//Used in: NoteEditorView, NoteDetailView


import Foundation
import SwiftUI
import PhotosUI

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Fetch notes for a specific user
    func fetchNotes(for userId: String) {
        isLoading = true
        FirebaseService.shared.getCollection(
            collection: "notes",
            model: Note.self,
            filters: [["userId": userId]]
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let notes):
                    self?.notes = notes
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // Create a new note
    func createNewNote(for userId: String, completion: @escaping (Note) -> Void) {
        let newNote = Note(
            id: UUID().uuidString,
            userId: userId,
            title: "",
            content: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        FirebaseService.shared.setDocument(
            collection: "notes",
            documentId: newNote.id,
            data: newNote
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(newNote)
                case .failure(let error):
                    print("❌ Failed to create note: \(error.localizedDescription)")
                }
            }
        }
    }

    // Update a note
    func update(note: Note, completion: (() -> Void)? = nil) {
        var updatedNote = note
        updatedNote.updatedAt = Date()
        FirebaseService.shared.setDocument(
            collection: "notes",
            documentId: updatedNote.id,
            data: updatedNote
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Note updated successfully.")
                case .failure(let error):
                    print("❌ Failed to update note: \(error.localizedDescription)")
                }
                completion?()
            }
        }
    }

    func uploadImageAndAdd(to note: Note, item: PhotosPickerItem, completion: ((Note) -> Void)? = nil) {
        Task {
            do {
                guard let imageData = try await item.loadTransferable(type: Data.self) else {
                    print("❌ Could not extract image data.")
                    return
                }

                CloudinaryService.shared.uploadPhoto(imageData: imageData) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let url):
                            var updatedNote = note
                            updatedNote.content.append(url)
                            self.update(note: updatedNote) {
                                completion?(updatedNote)
                            }
                        case .failure(let error):
                            print("❌ Image upload failed: \(error.localizedDescription)")
                        }
                    }
                }
            } catch {
                print("❌ Failed to load image data: \(error.localizedDescription)")
            }
        }
    }
    
    func submitQuestion(for note: Note, userQuestion: String, completion: @escaping (Result<String, Error>) -> Void) {
        let context = (note.title.isEmpty ? "" : ("Title:" + note.title + "\n") ) + "Notes:" + note.content.joined(separator: "\n")

        AIService.shared.askQuestion(context: context, question: userQuestion) { result in
            completion(result)
        }
    }
}
