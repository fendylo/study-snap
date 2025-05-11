import Foundation
import FirebaseAuth
import FirebaseFirestore

// NOTE:
// Firebase Authentication
// Firestore CRUD

class FirebaseService {
    static let shared = FirebaseService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Firebase Auth

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = result?.user {
                self.fetchUserProfile(firebaseUser: firebaseUser, completion: completion)
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = result?.user {
                self.fetchUserProfile(firebaseUser: firebaseUser, completion: completion)
            }
        }
    }

    func signOut() throws {
        try auth.signOut()
    }

    func getCurrentUser(completion: @escaping (User?) -> Void) {
        guard let firebaseUser = auth.currentUser else {
            completion(nil)
            return
        }

        fetchUserProfile(firebaseUser: firebaseUser) { result in
            switch result {
            case .success(let user):
                UserDefaultUtil.set(user, forKey: "currentUser")
                completion(user)
            case .failure(let error):
                print("❌ Failed to fetch user profile: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // function to return User object from firestore and authentication data
    private func fetchUserProfile(firebaseUser: FirebaseAuth.User, completion: @escaping (Result<User, Error>) -> Void) {
        let userId = firebaseUser.uid
        
        FirebaseService.shared.getDocument(collection: "users", documentId: userId, model: User.self) { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                print("❌ Failed to fetch or decode user profile: \(error.localizedDescription)")
                print("➡️ Falling back to basic FirebaseAuth user info.")
                let fallbackUser = User(firebaseUser: firebaseUser)
                completion(.success(fallbackUser))
            }
        }
    }
    
    // MARK: - Generic Firestore CRUD Operations

    // Create or Update document
    func setDocument<T: Encodable>(collection: String, documentId: String? = nil, data: T, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let encodedData = try Firestore.Encoder().encode(data)
            let ref = documentId != nil ? db.collection(collection).document(documentId!) : db.collection(collection).document()
            ref.setData(encodedData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    // Get document by ID
    func getDocument<T: Decodable>(collection: String, documentId: String, model: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        db.collection(collection).document(documentId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = try? snapshot?.data(as: model) {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "DecodeError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode document"])) )
            }
        }
    }

    // Query collection with optional filters
    func getCollection<T: Decodable>(
        collection: String,
        model: T.Type,
        filters: [[String: Any]] = [],
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var query: Query = db.collection(collection)

        for filter in filters {
            if let field = filter.keys.first,
               let value = filter[field] {
                query = query.whereField(field, isEqualTo: value)
            }
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                let models: [T] = documents.compactMap { try? $0.data(as: T.self) }
                completion(.success(models))
            } else {
                completion(.success([]))
            }
        }
    }

    // Delete document
    func deleteDocument(collection: String, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection).document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func mergeDocument(
        collection: String,
        documentId: String,
        data: [String: Any],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let ref = db.collection(collection).document(documentId)
        ref.setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}


