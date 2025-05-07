//
//  UpdateDetailsView.swift
//  StudySnap
//
//  Created by Hasin Sadique on 8/5/25.
//

import SwiftUI
import FirebaseFirestore

struct UpdateDetailsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var major: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            // Spacer()
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Personal Information")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 8)
                        .foregroundColor(Color("Primary"))
                    
                    Spacer()
                    VStack(spacing: 12) {

                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(Color("Primary"))
                                .padding(.bottom, 20)
                        }
                        .frame(maxWidth: .infinity)


                        TextField("Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .cornerRadius(12)
                            
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.horizontal)
                            .cornerRadius(12)
                            .disabled(true)
                            .foregroundColor(.gray)
                        
                        TextField("Major", text: $major)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    Spacer()
                    Button(action: updateUserDetails) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Primary"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .disabled(isLoading)
                .shadow(radius: 3)
                .padding(.horizontal)
                }
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color("Secondary"), Color("Tertiary")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                )
                .cornerRadius(15)
                .shadow(radius: 5)
                // .background(
                //     .ultraThinMaterial
                // )
                
                
            }
            .padding()
        }
        .navigationTitle("Update Details")
            .foregroundStyle(Color("Primary"))
        
        .onAppear {
            if let user = authVM.user {
                name = user.name
                email = user.email
                major = user.educationMajor
            }
        }
        .alert("Update Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func updateUserDetails() {
        guard let userId = authVM.user?.id else { return }
        
        isLoading = true
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        let updatedData: [String: Any] = [
            "name": name,
            "email": email,
            "educationMajor": major
        ]
        
        userRef.updateData(updatedData) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Error updating details: \(error.localizedDescription)"
            } else {
                alertMessage = "Details updated successfully!"
                // Update local user data
                if var user = authVM.user {
                    user.name = name
                    user.email = email
                    user.educationMajor = major
                    authVM.user = user
                }
            }
            showAlert = true
        }
    }
}

struct UpdateDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UpdateDetailsView()
                .environmentObject(AuthViewModel())
        }
    }
}



