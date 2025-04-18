//
//  OpenAIService.swift
//  TrainingTroughs
//
//  Created by Bob Kitchen on 4/18/25.
//


//  OpenAIService.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 4/18/25.
//

import Foundation

@MainActor
class OpenAIService {
  private let apiKey: String
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()

  init(apiKey: String) {
    self.apiKey = apiKey
  }

  /// Sends a prompt to OpenAI and returns the assistant’s reply text.
  func send(prompt: String) async throws -> String {
    let url = URL(string: "https://api.openai.com/v1/completions")!
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // you can tweak model, max_tokens, etc.
    struct Body: Encodable {
      let model = "text-davinci-003"
      let prompt: String
      let max_tokens = 512
      let temperature = 0.7
    }

    req.httpBody = try encoder.encode(Body(prompt: prompt))

    let (data, response) = try await URLSession.shared.data(for: req)
    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    let openAI = try decoder.decode(OpenAIResponse.self, from: data)
    return openAI.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  }
}