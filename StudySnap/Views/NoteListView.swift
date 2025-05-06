//
//  NoteView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

struct NoteListView: View {
    @ObservedObject private var nav = NavigationUtil.shared
    @StateObject private var viewModel = NoteViewModel()
    @State private var currentUserId: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("My Notes")
                .font(.title)

            if let storedUser = UserDefaultUtil.get(User.self, forKey: "currentUser") {
                LazyVStack(alignment: .leading, spacing: 12) {
                    let notes = viewModel.notes

                    ForEach(notes, id: \.id) { note in
                        NoteRowView(note: note)
                            .onTapGesture {
                                // nav.navigate(to: .noteDetails(note: note))
                            }
                    }
                }
                .onAppear {
                    currentUserId = storedUser.id
                    viewModel.fetchNotes(for: currentUserId)
                }
            } else {
                Text("No user found.")
                    .foregroundColor(.red)
            }

            Spacer()

            Button("+ New Note") {
                viewModel.createNewNote(for: currentUserId) { newNote in
                    nav.navigate(to: .noteDetails(note: newNote))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("Primary"))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}


struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title.isEmpty ? "Untitled Note" : note.title)
                .font(.headline)

            Text(note.content.first ?? "")
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteListView()
    }
}
