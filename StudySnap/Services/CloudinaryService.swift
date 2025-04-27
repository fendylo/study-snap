//
//  CloudinaryService.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import Foundation
import UniformTypeIdentifiers

class CloudinaryService {
    static let shared = CloudinaryService()

    private let cloudName = ProcessInfo.processInfo.environment["CLOUDINARY_CLOUD_NAME"] ?? ""
    private let uploadPreset = ProcessInfo.processInfo.environment["CLOUDINARY_UPLOAD_PRESET"] ?? ""

    func uploadPhoto(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload") else {
            completion(.failure(NSError(domain: "Invalid Cloudinary URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = self.createMultipartBody(data: imageData, boundary: boundary)
        request.httpBody = body

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(for: request)

                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let secureUrl = json["secure_url"] as? String else {
                    completion(.failure(NSError(domain: "Failed to parse Cloudinary response", code: 0)))
                    return
                }

                completion(.success(secureUrl))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func createMultipartBody(data: Data, boundary: String) -> Data {
        var body = Data()

        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}
