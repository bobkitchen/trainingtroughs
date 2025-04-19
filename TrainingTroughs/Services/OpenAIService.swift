//
//  OpenAIService.swift
//  TrainingTroughs
//
//  Minimal wrapper around OpenAI “chat completions”.
//

import Foundation

struct OpenAIError: Decodable, Error {
    let message: String
}

@MainActor
final class OpenAIService: ObservableObject {

    private let session = URLSession.shared
    private let apiKey: String

    init(apiKey: String) { self.apiKey = apiKey }

    /// Send a single‑turn prompt, get the assistant’s reply text.
    func send(_ prompt: String) async throws -> String {

        struct Msg: Codable { let role, content: String }
        struct Req:  Codable { let model: String, messages: [Msg] }
        struct Choice: Decodable { let message: Msg }
        struct Res:    Decodable { let choices: [Choice] }

        let body = try JSONEncoder().encode(
            Req(model: "gpt-3.5-turbo",
                messages: [.init(role: "user", content: prompt)]))

        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json",   forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        let (data, resp) = try await session.data(for: req)

        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            if let err = try? JSONDecoder().decode(OpenAIError.self, from: data) {
                throw err
            }
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Res.self, from: data).choices.first?.message.content ?? ""
    }
}
