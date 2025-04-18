//  ChatMessage.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 4/18/25.
//

import Foundation

struct ChatMessage: Identifiable {
  let id = UUID()
  let role: Role
  let content: String

  enum Role {
    case user, assistant
  }
}
