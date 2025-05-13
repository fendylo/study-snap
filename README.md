# 📘 StudySnap: Smart Study Companion

**GitHub:** https://github.com/fendylo/study-snap

StudySnap is an iOS native app built with **SwiftUI** that empowers students to capture notes, query them with AI, auto-generate quizzes, and track progress on a beautiful dashboard. Backed by Firebase (Auth + Firestore) and Groq API for AI, it follows a clean MVVM architecture for maintainability and scalability.

---

## 🎨 UI Preview

| **Home (Notes List)** | **Note Taking** |
| :-: | :-: |
| <img src="https://res.cloudinary.com/promptvisionai/image/upload/v1747098452/Screenshot_2025-05-13_at_11.03.51_am_jzdahf.png" width="300"/> | <img src="https://res.cloudinary.com/promptvisionai/image/upload/v1747099002/Screenshot_2025-05-13_at_11.16.10_am_wc9s6c.png" width="300"/> |

| **Quiz Taking** | **Dashboard** |
| :-: | :-: |
| <img src="https://res.cloudinary.com/promptvisionai/image/upload/v1747098451/Screenshot_2025-05-13_at_11.04.25_am_re9n1n.png" width="300"/> | <img src="https://res.cloudinary.com/promptvisionai/image/upload/v1747098452/Screenshot_2025-05-13_at_11.04.55_am_xobo7m.png" width="300"/> |

---

## 🔍 Features

- **Note Management**: Create, edit, and organise text & image notes.  
- **AI Assistant**: Ask questions about your notes; answers powered by Groq LLM.  
- **Quiz Generation**: Auto-create multiple-choice quizzes from your note content.  
- **Performance Dashboard**: Visualise quiz scores, track progress by topic, and get AI feedback.  
- **Secure Auth**: Firebase Authentication & Firestore for data sync.  
- **Image Uploads**: Cloudinary integration for fast, reliable media storage.

---

## 📁 Project Structure

| Folder / File                | Purpose                                                                                          |
| :--------------------------- | :----------------------------------------------------------------------------------------------- |
| **Models/**                  | Data structures (`User`, `Note`, `Quiz`, etc.)                                                   |
| **Services/**                | API & backend layers (`FirebaseService`, `CloudinaryService`, `AIService`)                      |
| **Utilities/**               | Helpers (`UserDefaultsUtil`, `NavigationUtil`, constants)                                       |
| **ViewModels/**              | MVVM state & logic (`AuthViewModel`, `NoteViewModel`, `DashboardViewModel`, `QuizViewModel`)    |
| **Views/**                   | SwiftUI screens & components (`LoginView`, `NoteListView`, `NoteDetailsView`, `DashboardView`) |
| **StudySnapApp.swift**       | App entry point (`@main`), injects environment objects                                         |
| **GoogleService-Info.plist** | Firebase config                                                                                |
| **.env**                     | Environment variables (API keys, Cloudinary presets)                                            |

---

## 🧰 Tech Stack

- **Language:** Swift 5.x  
- **UI:** SwiftUI  
- **Backend:** Firebase Auth & Firestore  
- **Storage:** Cloudinary  
- **AI:** Groq API  

---

## 🚀 Getting Started

1. Clone the repo.  
2. Add `GoogleService-Info.plist` (Firebase).  
3. Create an `.env` with your Groq API key & Cloudinary credentials.  
4. Install Swift Packages if prompted.  
5. Build & run on Simulator or device.

---

## 👥 Team

- **Fendy Lomanjaya**  
- **Mohammad Hasin Bin Sadique**  
- **Arbaz Rahimbhai Malek**

*Crafted with clean architecture and modern UI/UX for focused, AI-powered studying.*  
