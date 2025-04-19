//
//  ChatViewModel.swift
//  TrainingTroughs
//
//  FINAL – 19 Apr 2025
//

import SwiftUI

/// A single message in the chat.
struct ChatMessage: Identifiable, Hashable {
  enum Role: String, Codable {
    case user, assistant
  }
  let id = UUID()
  let role: Role
  let content: String
}

@MainActor
class ChatViewModel: ObservableObject {
  // MARK: – State
  @Published var messages: [ChatMessage] = []
  @Published var input: String = ""

  // MARK: – Dependency
  private let service: OpenAIService

  init(service: OpenAIService) {
    self.service = service
  }

  // MARK: – Public API
  /// Sends the current `input`, appends both user and assistant messages.
  func send() async {
    // 1. Append the user’s message
    let userMsg = ChatMessage(role: .user, content: input)
    messages.append(userMsg)
    input = ""

    // 2. Ask OpenAI for a reply
    do {
      let assistantText = try await service.send(userMsg.content)
      let assistantMsg = ChatMessage(role: .assistant, content: assistantText)
      messages.append(assistantMsg)
    } catch {
      let errorMsg = ChatMessage(
        role: .assistant,
        content: "⚠️ Error: \(error.localizedDescription)"
      )
      messages.append(errorMsg)
    }
  }
}
