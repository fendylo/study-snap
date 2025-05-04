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
            HStack {
                Text("📝 My Notes")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color("Primary"))
                Spacer()
            }

            if let storedUser = UserDefaultUtil.get(User.self, forKey: "currentUser") {
                if viewModel.notes.isEmpty {
                    Spacer()
                    Text("No notes yet. Tap + New Note to get started!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.notes, id: \.id) { note in
                                NoteRowView(note: note)
                                    .onTapGesture {
                                        nav.navigate(to: .noteDetails(note: note))
                                    }
                                    .transition(.scale)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                Text("⚠️ No user found.")
                    .foregroundColor(.red)
            }

            Button(action: {
                viewModel.createNewNote(for: currentUserId) { newNote in
                    nav.navigate(to: .noteDetails(note: newNote))
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Note")
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("Primary"))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 4)
            }
            .padding(.top)

        }
        .padding()
        .onAppear {
            if let storedUser = UserDefaultUtil.get(User.self, forKey: "currentUser") {
                currentUserId = storedUser.id
                viewModel.fetchNotes(for: currentUserId)
            }
        }
    }
}

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title.isEmpty ? "Untitled Note" : note.title)
                .font(.headline)
                .foregroundColor(Color("Primary"))

            if let firstLine = note.content.first, !firstLine.starts(with: "http") {
                Text(firstLine)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Secondary").opacity(0.15))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: note.id)
    }
}
#Preview {
    NoteListView()
}
