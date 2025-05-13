//
//  NoteView.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import SwiftUI

// a page that shows the list of note
struct NoteListView: View {
    @ObservedObject private var nav = NavigationUtil.shared
    @StateObject private var viewModel = NoteViewModel()
    @State private var currentUserId: String = ""

    var body: some View {
        ZStack {
            // MARK: — Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: — Header
                HStack {
                    Text("📝 My Notes")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        viewModel.fetchNotes(for: currentUserId)
                    } label: {
                        Image(systemName: "arrow.clockwise.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()

                // MARK: — Content
                if viewModel.notes.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "note.text.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white.opacity(0.7))
                        Text("No notes yet")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        Text("Tap the + button to create your first note.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.notes) { note in
                                NoteCardView(note: note)
                                    .onTapGesture {
                                        nav.navigate(to: .noteDetails(note: note))
                                    }
                                    .animation(.spring(), value: note.id)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        // MARK: — Floating Add Button
        .overlay(
            Button(action: {
                viewModel.createNewNote(for: currentUserId) { newNote in
                    nav.navigate(to: .noteDetails(note: newNote))
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("Primary"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(),
            alignment: .bottomTrailing
        )
        .onAppear {
            if let user = UserDefaultUtil.get(User.self, forKey: "currentUser") {
                currentUserId = user.id
                viewModel.fetchNotes(for: currentUserId)
            }
        }
    }
}

struct NoteCardView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title.isEmpty ? "Untitled Note" : note.title)
                .font(.headline)
                .foregroundColor(.primary)

            if let snippet = note.content.first(where: { !$0.starts(with: "http") }) {
                Text(snippet)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Spacer()
                Text(note.updatedAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color("Secondary").opacity(0.2))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    NoteListView()
}
