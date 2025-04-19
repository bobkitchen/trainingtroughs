//
//  OpenAIService.swift
//  TrainingTroughs
//
//  Minimal streaming‑optional wrapper around /v1/chat/completions
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    var id = UUID()
    let role   : Role
    let content: String
    
    enum Role: String, Codable { case user, assistant }
    
    init(role: Role, content: String) {
        self.role    = role
        self.content = content
    }
}

// MARK: - Service
final class OpenAIService: ObservableObject {
    private let apiKey: String
    
    init?() {
        guard let k = KeychainHelper.get("openai_api_key"), !k.isEmpty else { return nil }
        apiKey = k
    }
    
    /// Blocking one‑shot request (simplest possible)
    func send(_ userText: String) async throws -> String {
        struct Msg: Codable { let role, content: String }
        struct Req: Codable { let model = "gpt-3.5-turbo", messages: [Msg] }
        struct Res: Codable {
            struct Choice: Codable { let message: Msg }
            let choices: [Choice]
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)",      forHTTPHeaderField: "Authorization")
        req.setValue("application/json",      forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode( Req(messages: [.init(role: "user", content: userText)]) )
        
        let (data, _) = try await URLSession.shared.data(for: req)
        let res = try JSONDecoder().decode(Res.self, from: data)
        return res.choices.first?.message.content ?? ""
    }
}
