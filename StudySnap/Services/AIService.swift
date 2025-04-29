//
//  AIService.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

// NOTE:
//This is a file to send API Request to Groq
//Every function that needs to be integrated with groq, call this function
//For usage example, please review the QuizViewModel.swift "generateQuiz" function

import Foundation

class AIService {
    static let shared = AIService()

    private let apiKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"] ?? ""
    private let endpoint = "https://api.groq.com/openai/v1/chat/completions"
    private let modelName = ProcessInfo.processInfo.environment["GROQ_MODEL_NAME"] ?? ""
    private let modelTemperature = 0.5

    // Generalised AI POST REST Request that returns only the assistant's text content
    func sendRequest(systemPrompt: String, userPrompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        let body: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": modelTemperature
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("close", forHTTPHeaderField: "Connection")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.httpShouldUsePipelining = false
        config.httpShouldSetCookies = false
        config.multipathServiceType = .none
        config.httpMaximumConnectionsPerHost = 1
        let session = URLSession(configuration: config)

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }

            do {
                let groqResponse = try JSONDecoder().decode(GroqCompletionResponse.self, from: data)
                if let content = groqResponse.choices.first?.message.content {
                    completion(.success(content))
                } else {
                    completion(.failure(NSError(domain: "Empty content", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
}

// Supporting decoding model
struct GroqCompletionResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }
    struct Message: Codable {
        let role: String
        let content: String
    }
    let choices: [Choice]
}
