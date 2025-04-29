//
//  AIService.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 21/4/2025.
//

// NOTE:
//This is a file to interact with the AI API
//Sends structured prompts to Groq/OpenAI
//
//Functions:
//
//highlightNoteTopic(content: String)
//
//generateQuiz(note: String)
//
//Includes output parser to transform AI responses into Flashcard or Quiz models


import Foundation

class AIService {
    static let shared = AIService()

    private let apiKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"] ?? ""
    private let endpoint = "https://api.groq.com/openai/v1/chat/completions" // Example for Groq or OpenAI
    private let modelName = ProcessInfo.processInfo.environment["GROQ_MODEL_NAME"] ?? ""
    private let modelTemperature = 0.5

    func askQuestion(context: String, question: String, completion: @escaping (Result<String, Error>) -> Void) {
        print(context)
        print(question)
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        let systemPrompt = """
        You are a helpful expert study assistant. Based on the provided note context, answer the user's question as clearly, concisely, and accurately as possible.

        If the answer is not explicitly stated in the context, you must then **make the best reasonable guess** based on the information.

        Note Context:
        \(context)
        """

        let body: [String: Any] = [
            "model": modelName, // Or whichever model you're using
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": question]
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
            print("RESPONSE FROM AI ENDPOINT CALL")
            print(data)
            print("ERROR: ")
            print(error)
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let response = try? JSONDecoder().decode(GroqCompletionResponse.self, from: data),
                  let content = response.choices.first?.message.content else {
                completion(.failure(NSError(domain: "Failed to parse AI response", code: 0)))
                return
            }
            
            print("RESPONSE")
            print(response)
            
            print("Successfully decoded")
            print(content)

            completion(.success(content))
        }.resume()
    }
}

// Supporting response decoding
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


//import Foundation
//
//class AIService {
//    static let shared = AIService()
//
//    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
//    private let endpoint = "https://api.openai.com/v1/chat/completions"
//    private let modelName = ProcessInfo.processInfo.environment["OPENAI_MODEL_NAME"] ?? "gpt-3.5-turbo"
//    private let modelTemperature = 0.5
//
//    func askQuestion(context: String, question: String, completion: @escaping (Result<String, Error>) -> Void) {
//        print("🧠 Context Sent to AI:")
//        print(context)
//        print("❓ Question:")
//        print(question)
//
//        guard let url = URL(string: endpoint) else {
//            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
//            return
//        }
//
//        let systemPrompt = """
//        You are an expert study assistant. Based on the provided note context, answer the user's question as clearly, concisely, and accurately as possible.
//
//        Note Context:
//        \(context)
//        """
//
//        let body: [String: Any] = [
//            "model": modelName,
//            "messages": [
//                ["role": "system", "content": systemPrompt],
//                ["role": "user", "content": question]
//            ],
//            "temperature": modelTemperature
//        ]
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            completion(.failure(error))
//            return
//        }
//
//        // Safer custom URLSession with long timeout and stable connection
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = 60 // seconds
//        config.timeoutIntervalForResource = 90 // seconds
//        config.httpShouldUsePipelining = false
//        config.httpShouldSetCookies = false
//        config.httpMaximumConnectionsPerHost = 1
//        config.waitsForConnectivity = true
//        config.multipathServiceType = .none // Avoid unstable network path switching
//        let session = URLSession(configuration: config)
//
//        session.dataTask(with: request) { data, _, error in
//            print("DATA")
//            print(data)
//            print("ERROR")
//            print(error)
//            if let error = error {
//                print("❌ AI API Request Error: \(error.localizedDescription)")
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(NSError(domain: "No data received from AI", code: 0)))
//                return
//            }
//
//            do {
//                let decoded = try JSONDecoder().decode(OpenAICompletionResponse.self, from: data)
//                if let content = decoded.choices.first?.message.content {
//                    completion(.success(content))
//                } else {
//                    completion(.failure(NSError(domain: "AI returned no content", code: 0)))
//                }
//            } catch {
//                print("❌ Failed to decode AI response: \(error.localizedDescription)")
//                completion(.failure(error))
//            }
//
//        }.resume()
//    }
//}
//
//// Supporting OpenAI response decoding
//struct OpenAICompletionResponse: Codable {
//    struct Choice: Codable {
//        let message: Message
//    }
//    struct Message: Codable {
//        let role: String
//        let content: String
//    }
//    let choices: [Choice]
//}
