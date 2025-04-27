import Foundation
import FirebaseAuth
import FirebaseFirestore

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
                let customUser = User(firebaseUser: firebaseUser)
                completion(.success(customUser))
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = result?.user {
                let customUser = User(firebaseUser: firebaseUser)
                completion(.success(customUser))
            }
        }
    }

    func signOut() throws {
        try auth.signOut()
    }

    func getCurrentUser() -> User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return User(firebaseUser: firebaseUser)
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
}
