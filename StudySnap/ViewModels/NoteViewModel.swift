//
//  NoteViewModel.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

//NOTE:
//Upload typed or image-based notes
//
//Ask AI questions about the user's note
//
//Interacts with AIService and FirebaseService
//
//Used in: NoteView, NoteDetailView


import Foundation
import SwiftUI
import PhotosUI


// a view model to CRUD note
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
    
    func delete(note: Note, completion: @escaping (Bool) -> Void) {
        FirebaseService.shared.deleteDocument(
            collection: "notes",
            documentId: note.id
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("🗑️ Successfully deleted note: \(note.id)")
                    // Optionally remove from local notes array
                    self.notes.removeAll { $0.id == note.id }
                    completion(true)
                case .failure(let error):
                    print("❌ Error deleting note: \(error.localizedDescription)")
                    completion(false)
                }
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
    
    // Submit question related to a note
    func submitQuestion(for note: Note, userQuestion: String, completion: @escaping (Result<String, Error>) -> Void) {
        let pureTexts = note.content.filter { !$0.lowercased().starts(with: "http") }
        let context = pureTexts.joined(separator: "\n")

        let systemPrompt = """
        You are a helpful expert study assistant. Based on the provided note context, answer the user's question as clearly, concisely, and accurately as possible.

        If the answer is not explicitly stated in the context, you must then **make the best reasonable guess** based on the information.

        Note Context:
        \(context)
        """

        AIService.shared.sendRequest(systemPrompt: systemPrompt, userPrompt: userQuestion) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
