//
//  ChatViewModel.swift
//  TrainingTroughs
//
//  Created by Bob Kitchen on 4/18/25.
//


//  ChatViewModel.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 4/18/25.
//

import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
  @Published var messages: [ChatMessage] = []
  @Published var input: String = ""

  private let service: OpenAIService

  init(service: OpenAIService) {
    self.service = service
  }

  func send() async {
    let user = ChatMessage(role: .user, content: input)
    messages.append(user)
    input = ""
    do {
      let reply = try await service.send(prompt: user.content)
      messages.append(ChatMessage(role: .assistant, content: reply))
    } catch {
      messages.append(ChatMessage(role: .assistant, content: "⚠️ Error: \(error.localizedDescription)"))
    }
  }
}