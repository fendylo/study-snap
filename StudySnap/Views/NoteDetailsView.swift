//
//  NoteDetailView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI
import PhotosUI

struct NoteDetailsView: View {
    @State var note: Note
    @StateObject private var viewModel = NoteViewModel()
    @State private var newText: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Note Title", text: $note.title)
                    .font(.title.bold())
                    .padding(.horizontal)
                    .onSubmit {
                        viewModel.update(note: note)
                    }

                Text("Last updated: \(note.updatedAt.formatted())")
                    .font(.caption)
                    .padding(.horizontal)

                Divider()

                ForEach(note.content, id: \ .self) { item in
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
                    }
                }

                Divider()

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
    }
}

#Preview {
    NoteDetailsView(note: Note(
        id: UUID().uuidString,
        userId: "123",
        title: "This is title",
        content: [],
        createdAt: Date(),
        updatedAt: Date()
    ))
}
