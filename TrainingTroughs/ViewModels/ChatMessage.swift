//
//  ChatMessage.swift
//  TrainingTroughs
//

import Foundation

/// A single bubble in the chat.
struct ChatMessage: Identifiable, Hashable, Codable {
    enum Role: String, Codable { case user, assistant }

    let id   = UUID()
    let role: Role
    let content: String
}
