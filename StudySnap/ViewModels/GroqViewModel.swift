import Foundation
import Combine

class GroqViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var responseText: String = ""
    @Published var isLoading: Bool = false
    
    private let modelName = "llama3-8b-8192"
    private let apiKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"]
    private let endpoint = "https://api.groq.com/openai/v1/chat/completions"

    func sendPrompt() {
        guard let url = URL(string: endpoint),
              let apiKey = apiKey else {
            print("Invalid URL or missing API key.")
            return
        }

        isLoading = true
        responseText = ""

        let requestData: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestData) else {
            print("Failed to encode request body")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.responseText = "Request error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.responseText = "No data received"
                }
                return
            }

            do {
                let result = try JSONDecoder().decode(GroqResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.responseText = result.choices.first?.message.content ?? "No response"
                }
            } catch {
                DispatchQueue.main.async {
                    self?.responseText = "Failed to parse response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - Response Structs
struct GroqResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }
    struct Message: Codable {
        let role: String
        let content: String
    }
    let choices: [Choice]
}
