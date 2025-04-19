//
//  ChatViewModel.swift
//  TrainingTroughs
//  FINAL – 19 Apr 2025
//

import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {

    // ── Published state ───────────────────────────────────────────────
    @Published var messages: [ChatMessage] = []
    @Published var input:    String = ""

    // ── Dependency ────────────────────────────────────────────────────
    private let service: OpenAIService
    init(service: OpenAIService) { self.service = service }

    // ── Public API ────────────────────────────────────────────────────
    func send() async {
        // 1. append the user’s message
        let userMsg = ChatMessage(role: .user, content: input)
        messages.append(userMsg)
        input = ""

        do {
            // 2. ask OpenAI for a reply
            let assistantText = try await service.send(userMsg.content)
            let assistantMsg  = ChatMessage(role: .assistant, content: assistantText)
            messages.append(assistantMsg)

        } catch {
            // 3. simple error bubble
            let errorMsg = ChatMessage(
                role:    .assistant,
                content: "⚠️ Error: \(error.localizedDescription)"
            )
            messages.append(errorMsg)
        }
    }
}
